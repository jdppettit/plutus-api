defmodule PlutusWeb.Params.StringDate do
  use Ecto.Type
  
  def type, do: :string

  def cast(date) when is_binary(date) do
    date = case Jason.decode(date) do
      {:ok, parsed_date} -> parsed_date
      _ -> date
    end
    {:ok, date} = Timex.parse(date, "{YYYY}-{0M}-{0D}")
  end

  def cast(_), do: :error

  def load(date), do: date

  def dump(date), do: date
end