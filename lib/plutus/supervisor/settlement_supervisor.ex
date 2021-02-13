defmodule Plutus.Supervisor.SettlementSupervisor do
  use DynamicSupervisor

  alias Plutus.Worker

  require Logger

  def start_link(_arg) do
    Logger.debug("#{__MODULE__}: SettlementSupervisor starting")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    spawn_workers()

  end

  def init(:ok) do
    DynamicSupervisor.init([
      strategy: :one_for_one,
      max_restarts: 1000,
      max_seconds: 5
    ])
  end

  def spawn_workers do
    Logger.debug("#{__MODULE__}: Starting settlement workers")
    DynamicSupervisor.start_child(__MODULE__, %{
      id: Worker.SettlementhWorker,
      start: {Worker.SettlementWorker, :start_link, []}
    })
  end
end