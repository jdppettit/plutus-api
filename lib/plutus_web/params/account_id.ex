defmodule PlutusWeb.Params.AccountId do
  use Ecto.Type
  
  alias Plutus.Model.Account

  def type, do: :integer

  def cast(id) when is_integer(id) do
    get_account(id)
  end

  def cast(id) when is_binary(id) do
    {parsed_id, _} = Integer.parse(id)
    get_account(parsed_id)
  end

  def cast(_), do: :error

  # Used for loading into storage
  def load(id), do: id

  # Dumping transform to raw format (i.e. obfuscated)
  def dump(id), do: id

  def get_account(id) do
    case Account.get_by_id(id) do
      {:ok, _account} ->
        {:ok, id}
      _ ->
        :error
    end 
  end
end