defmodule PlutusWeb.AccountController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Account
  alias Plutus.Common.Balance
  alias Plutus.Worker.{AccountWorker,TransactionWorker}
  alias PlutusWeb.Params.{AccountId,AccountType} 

  require Logger

  def link_token(conn, _params) do
    {:ok, response} = Plaid.Link.create_link_token(%{
      client_name: "Plutus Money",
      language: "en",
      country_codes: ["US"],
      products: ["transactions"],
      user: %{
        client_user_id: "plutus_money"
      }
    })

    conn
    |> put_status(200)
    |> render("link_token.json", link_token: response.link_token)
  end

  defparams(
    create_params(%{
      description: :string,
      public_token!: :string,
      account_name: :string,
      last_four: :integer,
      remote_id: :string,
      type: AccountType,
      balance_to_maintain: :float,
      include_in_overall: :boolean
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params) |> IO.inspect},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, %{access_token: access_token} = resp} <- Plaid.Item.exchange_public_token(%{public_token: raw_params["public_token"]}) |> IO.inspect,
         {:ok, plaid_info} <- Plaid.Accounts.get_balance(%{access_token: access_token, options: %{account_ids: [raw_params["remote_id"]]}}),
         {:ok, parsed_params} <- {:ok, update_params_with_balance(parsed_params, plaid_info)},
         {:ok, parsed_params} <- {:ok, Map.put(parsed_params, :access_token, access_token)},
         {:ok, changeset} <- Account.create_changeset(parsed_params),
         {:ok, model} <- Account.insert(changeset),
         :ok <- TransactionWorker.adhoc_process_transactions() do
      conn
      |> render("account_created.json", account: model) 
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")
      {:error, %Plaid.Error{error_code: "ITEM_LOGIN_REQUIRED"} = error} ->
        Logger.error("#{__MODULE__}: Got Plaid error indicating update flow is required for account")
        Logger.error("#{__MODULE__}: #{inspect(error)}")
        conn
        |> put_status(200)
        |> render("account_update_required.json", %{})
    end
  end

  defparams(
    exchange_params(%{
      remote_id!: :string,
      plubic_token!: :string
    })
  )

  def exchange(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, exchange_params(raw_params) |> IO.inspect},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, changeset} <- Account.create_changeset(parsed_params),
         {:ok, model} <- Account.insert(changeset) 
    do
      conn
      |> render("exchanged.json", model: model)
    else
      _ ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
    end
  end

  defparams(
    get_params(%{
      id!: :integer
    })
  )

  def get(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, model} <- Account.get_by_id(parsed_params.id),
         {:ok, model} <- Balance.add_computed_values(model) do
      conn
      |> render("account.json", account: model)
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render("bad_request.json", message: "not found")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")      
    end 
  end

  defparams(
    update_params(%{
      id!: AccountId,
      description: :string,
      type: AccountType,
      balance_to_maintain: :float,
      include_in_overall: :boolean
    })
  )

  def update(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, update_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, model} <- Account.update_account(parsed_params) do
      conn
      |> render("account_updated.json", account: model)
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")  
    end
  end

  def get_all(conn, _params) do
    with models <- Account.get_all_accounts(),
         models <- update_accounts_with_balance(models) do
      conn
      |> render("accounts.json", accounts: models)
    else 
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render("bad_request.json", message: "not found")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")
    end 
  end

  def update_balances(conn, _params) do
    with :ok <- AccountWorker.adhoc_refresh do
      conn
      |> render("update_balances.json")
    else
      _ ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "unexpected error")
    end
  end

  def update_params_with_balance(parsed_params, plaid_info) do
    [first_account | _] = plaid_info.accounts
    balance = first_account.balances.available
    Map.put(parsed_params, :balance, balance)
  end

  def update_accounts_with_balance(models) do
    models
    |> Enum.map(fn model -> 
      {:ok, model} = Balance.add_computed_values(model)
      model
    end)
  end
end