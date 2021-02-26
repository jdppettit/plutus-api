defmodule PlutusWeb.TransactionController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Transaction
  alias PlutusWeb.Params.{AccountId, TransactionId, StringDate}
  alias Plutus.Worker.TransactionWorker

  defparams(
    get_all_params(%{
      account_id!: AccountId
    })
  )

  def get_all(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_all_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, transactions} <- Transaction.get_all_transactions_for_account(parsed_params.account_id) do
      conn
      |> render("transactions.json", transactions: transactions)
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
      id!: TransactionId
    })
  )

  def get(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, transaction} <- Transaction.get_by_id(parsed_params.id) do
      conn
      |> render("transaction.json", transaction: transaction)
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
    get_window_params(%{
      account_id!: AccountId,
      window_start!: StringDate,
      window_end!: StringDate
    })
  )

  def get_by_window(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_window_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         transactions <- Transaction.get_by_window(parsed_params) do
      conn
      |> render("transactions.json", transactions: transactions)
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

  def update_transactions(conn, _params) do
    with :ok <- TransactionWorker.adhoc_process_transactions do
      conn
      |> render("update_transactions.json")
    else
      _ ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "process transaction failed")
    end
  end
end 
