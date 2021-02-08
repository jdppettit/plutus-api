defmodule Plutus.Types.Precompute do
  defstruct last_run: nil

  def build(map) do
    %__MODULE__{
      last_run: Map.get(map, :last_run, nil)
    }
  end

  def set_last_precompute_now(self) do
    self
    |> Map.replace(:last_run, DateTime.utc_now())
  end
end