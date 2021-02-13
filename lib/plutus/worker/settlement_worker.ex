defmodule Plutus.Worker.SettlementWorker do
  use GenServer

  alias Plutus.Model.{Account,Income,Expense,Event, Transaction}
  alias Plutus.Types.Precompute
  alias Plutus.Common.Date, as: PDate

  require Logger

  @interval 3_600_000 # 1 hour

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :settlement_worker
    )
  end

  def init(_) do
    Logger.debug("#{__MODULE__}: Initializing genserver for settlement processing")
    Process.send_after(self(), :settlement, 1_000)
    {:ok, nil}
  end

  def handle_info(:settlement, _) do
    Logger.debug("#{__MODULE__}: Starting settlement now")
    valid_accounts = Account.get_all_accounts() |> filter_valid_accounts()
    :ok = do_settlement(valid_accounts)
    Process.send_after(self(), :settlement, @interval)
    {:noreply, nil}
  end

  def do_settlement(accounts) do
    accounts
    |> Enum.map(fn account -> 
      Logger.debug("#{__MODULE__}: Starting settlment for account #{account.id}")
      Event.get_current_income_events(account.id) 
      |> Enum.with_index
      |> Enum.map(fn {event, index} -> 
        if index !== 0 do
          Logger.info("#{__MODULE__}: Settling income #{event.id}")
          Event.set_settled(event)
        end
      end)
    end)
    :ok
  end

  def filter_valid_accounts(accounts) do
    accounts
    |> Enum.filter(fn account -> 
      !is_nil(Map.get(account, :access_token, nil))
    end)
  end
end