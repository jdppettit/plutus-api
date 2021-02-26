defmodule PlutusWeb.IncomeController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.{Income,Event}
  alias Plutus.Worker.PrecomputeWorker
  alias PlutusWeb.Params.{AccountId, IncomeId}

  require Logger

  defparams(
    create_params(%{
      account_id!: AccountId,
      recurring: :boolean,
      day_of_month: :integer,
      day_of_week: :integer,
      amount: :float,
      description!: :string
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, changeset} <- Income.create_changeset(parsed_params),
         {:ok, model} <- Income.insert(changeset),
         :ok <- PrecomputeWorker.adhoc_precompute do
      conn
      |> render("income_created.json", income: model)
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
    get_all_params(%{
      account_id!: AccountId
    })
  )

  def get_all(conn, raw_params) do 
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_all_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, incomes} <- Income.get_all_income_for_account(parsed_params.account_id) do
      conn
      |> render("incomes.json", incomes: incomes)
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
      account_id!: AccountId,
      id!: IncomeId
    })
  )

  def get(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, income} <- Income.get_by_id(parsed_params.id) do
      conn
      |> render("income.json", income: income)
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
    delete_params(%{
      account_id!: AccountId,
      id!: IncomeId
    })
  )

  def delete(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, _} <- Income.delete_by_id(parsed_params.id),
         {:ok, _} <- Event.delete_by_parent_id(parsed_params.id),
          :ok <- PrecomputeWorker.adhoc_precompute do
      conn
      |> render("deleted.json", id: parsed_params.id)
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")
      _ ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "unexpected error")    
    end               
  end
end 