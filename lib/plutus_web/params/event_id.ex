defmodule PlutusWeb.Params.EventId do
  use Ecto.Type
  
  alias Plutus.Model.Event

  def type, do: :integer

  def cast(id) when is_integer(id) do
    get_event(id)
  end

  def cast(id) when is_binary(id) do
    {parsed_id, _} = Integer.parse(id)
    get_event(parsed_id)
  end

  def cast(_), do: :error

  def load(id), do: id

  def dump(id), do: id

  defp get_event(id) do
    case Event.get_by_id(id) do
      {:ok, _event} ->
        {:ok, id}
      _ ->
        :error
    end 
  end
end