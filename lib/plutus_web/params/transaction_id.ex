defmodule PlutusWeb.Params.TransactionId do
  use Ecto.Type
  
  alias Plutus.Models.Transaction

  def type, do: :integer

  def cast(id) when is_integer(id) do
    get_transaction(id)
  end

  def cast(id) when is_binary(id) do
    parsed_id = Integer.parse(id)
    get_transaction(parsed_id)
  end

  def cast(_), do: :error

  # Used for loading into storage
  def load(id), do: id

  # Dumping transform to raw format (i.e. obfuscated)
  def dump(id), do: id

  defp get_transaction(id) do
    case Transaction.get_by_id(id) do
      {:ok, _transaction} ->
        {:ok, id}
      _ ->
        :error
    end 
  end
end