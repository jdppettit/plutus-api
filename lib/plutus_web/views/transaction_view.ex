defmodule PlutusWeb.TransactionView do
  use PlutusWeb, :view

  def render("transaction_created.json", %{transaction: transaction}) do
    %{
      message: "transaction created successfully",
      transaction: %{id: transaction.id}
    }
  end

  def render("transactions.json", %{transactions: transactions}) do
    parsed_transactions = transactions
    |> Enum.map(fn transaction -> 
      %{
        id: transaction.id,
        description: transaction.description,
        amount: transaction.amount,
        pending: transaction.pending,
        date: transaction.date
      }
    end)
    %{
      message: "transactions retrieved successfully",
      transactions: parsed_transactions
    }
  end

  def render("bad_request.json", message) do
    %{
      message: message
    }
  end
end