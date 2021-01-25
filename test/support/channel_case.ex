defmodule PlutusWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import PlutusWeb.ChannelCase

      # The default endpoint for testing
      @endpoint PlutusWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Plutus.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Plutus.Repo, {:shared, self()})
    end

    :ok
  end
end
