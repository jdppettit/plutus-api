defmodule PlutusWeb.IncomeView do
  use PlutusWeb, :view

  def render("income_created.json", %{income: income}) do
    %{
      message: "income created successfully",
      income: %{id: income.id}
    }
  end

  def render("incomes.json", %{incomes: incomes}) do
    parsed_incomes = incomes
    |> Enum.map(fn income -> 
      %{
        id: income.id,
        account_id: income.account_id,
        description: income.description,
        recurring: income.recurring,
        day_of_month: income.day_of_month,
        day_of_week: income.day_of_week,
        amount: income.amount
      }
    end)
    %{
      message: "incomes retrieved successfully",
      incomes: parsed_incomes
    }
  end

  def render("income.json", %{income: income}) do
    %{
      message: "income retrieved successfully",
      income: %{
        id: income.id,
        account_id: income.account_id,
        description: income.description,
        recurring: income.recurring,
        day_of_month: income.day_of_month,
        day_of_week: income.day_of_week,
        amount: income.amount     
      }
    }
  end

  def render("bad_request.json", message) do
    %{
      message: message
    }
  end
end