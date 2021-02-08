defmodule PlutusWeb.Params.ExpenseId do
  use Ecto.Type
  
  alias Plutus.Model.Expense

  def type, do: :integer

  def cast(id) when is_integer(id) do
    get_expense(id)
  end

  def cast(id) when is_binary(id) do
    {parsed_id, _} = Integer.parse(id)
    get_expense(parsed_id)
  end

  def cast(_), do: :error

  # Used for loading into storage
  def load(id), do: id

  # Dumping transform to raw format (i.e. obfuscated)
  def dump(id), do: id

  defp get_expense(id) do
    case Expense.get_by_id(id) do
      {:ok, _expense} ->
        {:ok, id}
      _ ->
        :error
    end 
  end
end