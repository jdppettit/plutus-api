defmodule PlutusWeb.ExpenseController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Expense
  alias Plutus.Worker.PrecomputeWorker
  alias PlutusWeb.Params.{AccountId, ExpenseId, IncomeId}

  require Logger

  defparams(
    create_params(%{
      account_id!: AccountId,
      income_id!: IncomeId,
      amount: :float,
      description!: :string,
      transaction_description: :string
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, changeset} <- Expense.create_changeset(parsed_params),
         {:ok, model} <- Expense.insert(changeset),
         :ok <- PrecomputeWorker.adhoc_precompute do
      conn
      |> render("expense_created.json", expense: model)
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
      account_id!: AccountId,
      income_id!: IncomeId,
    })
  )

  def get_all(conn, raw_params) do 
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_all_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, expenses} <- Expense.get_all_expenses_for_income(parsed_params.income_id) do
      conn
      |> render("expenses.json", expenses: expenses)
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
      income_id!: IncomeId,
      id!: ExpenseId
    })
  )

  def get(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_all_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, expense} <- Expense.get_by_id(parsed_params.id) do
      conn
      |> render("expense.json", expense: expense)
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
end 