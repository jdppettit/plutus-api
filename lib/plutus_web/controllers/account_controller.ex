defmodule PlutusWeb.AccountController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Account

  require Logger

  def link_token(conn, _params) do
    {:ok, response} = Plaid.Link.create_link_token(%{
      client_name: "Demo",
      language: "en",
      country_codes: ["US"],
      products: ["auth", "transactions"],
      user: %{
        client_user_id: "1"
      }
    })
    IO.inspect(response)
    conn
    |> put_status(200)
    |> render("link_token.json", link_token: response.link_token)
  end

  defparams(
    create_params(%{
      description: :string,
      public_token!: :string
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, %{access_token: access_token} = resp} <- Plaid.Item.exchange_public_token(%{public_token: raw_params["public_token"]}),
         {:ok, parsed_params} <- {:ok, Map.put(raw_params, "access_token", access_token)},
         {:ok, changeset} <- Account.create_changeset(parsed_params),
         {:ok, model} <- Account.insert(changeset) do
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
         {:ok, model} <- Account.get_by_id(raw_params["id"]) do
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
end