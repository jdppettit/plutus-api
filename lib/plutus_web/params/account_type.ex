defmodule PlutusWeb.Params.AccountType do
  use Ecto.Type
  
  def type, do: :string

  def cast(type) when is_binary(type) do
    case Enum.member?(AccountType.__valid_values_(), type) do
      true ->
        {:ok, type}
      false ->
        :error
    end
  end

  def cast(_), do: :error

  def load(type), do: type

  def dump(type), do: type
end