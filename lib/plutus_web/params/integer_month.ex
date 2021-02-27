defmodule PlutusWeb.Params.IntegerMonth do
  use Ecto.Type

  def type, do: :integer

  def cast(month) when is_integer(month) do
    if month > 0 && month <= 12 do
      month
    else
      :error
    end
  end

  def cast(_), do: :error

  def load(month), do: month
  def dump(month), do: month
end