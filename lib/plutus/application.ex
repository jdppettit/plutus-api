defmodule Plutus.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Plutus.Repo, []),
      # Start the endpoint when the application starts
      supervisor(PlutusWeb.Endpoint, []),
      # Start your own worker by calling: Plutus.Worker.start_link(arg1, arg2, arg3)
      # worker(Plutus.Worker, [arg1, arg2, arg3]),
      %{
        id: Plutus.Supervisor.PlaidSupervisor,
        start: {Plutus.Supervisor.PlaidSupervisor, :start_link, [[]]}
      },
      %{
        id: Plutus.Supervisor.PrecomputeSupervisor,
        start: {Plutus.Supervisor.PrecomputeSupervisor, :start_link, [[]]}
      },
      %{
        id: Plutus.Supervisor.MatchSupervisor,
        start: {Plutus.Supervisor.MatchSupervisor, :start_link, [[]]}
      },
      %{
        id: Plutus.Supervisor.SettlementSupervisor,
        start: {Plutus.Supervisor.SettlementSupervisor, :start_link, [[]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plutus.Supervisor]
    Holidays.Definitions.Nyse.init() |> IO.inspect(label: "ret from holidays")
    {:ok, pid} = Supervisor.start_link(children, opts) |> IO.inspect(label: "expected")
    Plutus.Plaid.Categories.seed_categories()
    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PlutusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
