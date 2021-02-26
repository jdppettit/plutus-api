defmodule PlutusWeb.ExpenseView do
  use PlutusWeb, :view

  def render("expense_created.json", %{expense: expense}) do
    %{
      message: "expense created successfully",
      expense: %{id: expense.id}
    }
  end

  def render("expenses.json", %{expenses: expenses}) do
    parsed_expenses = expenses
    |> Enum.map(fn expense -> 
      %{
        id: expense.id,
        income_id: expense.income_id,
        description: expense.description,
        amount: expense.amount,
      }
    end)
    %{
      message: "expenses retrieved successfully",
      expenses: parsed_expenses
    }
  end

  def render("expense.json", %{expense: expense}) do
    %{
      message: "expense retrieved successfully",
      expense: %{
        id: expense.id,
        income_id: expense.income_id,
        description: expense.description,
        amount: expense.amount,
      }
    }
  end

  def render("bad_request.json", %{message: message}) do
    %{
      message: message
    }
  end
end