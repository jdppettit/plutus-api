defmodule Plutus.Worker.AccountWorker do
  use GenServer

  alias Plutus.Model.{Account}
  alias Plutus.Common.Date, as: PDate
  alias Plutus.Common.Utilities

  require Logger

  @interval 3_600_000 # 1 hour

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :account_worker
    )
  end

  def init(_) do
    Logger.info("#{__MODULE__}: Initializing genserver for account refresh processing")
    Process.send_after(self(), :account_refresh, 1_000)
    {:ok, nil}
  end

  def handle_info(:account_refresh, _) do
    Logger.info("#{__MODULE__}: Starting settlement now")
    valid_accounts = Account.get_all_accounts() 
    |> Utilities.filter_valid_accounts()
    :ok = do_account_refresh(valid_accounts)
    Process.send_after(self(), :account_refresh, @interval)
    {:noreply, nil}
  end

  def do_account_refresh(accounts) do
    accounts
    |> Enum.map(fn account -> 
      case Plaid.Accounts.get_balance(%{
        access_token: account.access_token, 
        options: %{account_ids: [account.remote_id]}}
      ) do
        {:ok, plaid_data} -> 
          [first_account | _] = plaid_data.accounts
          balance = first_account.balances.available
          Logger.info("#{__MODULE__}: Updating balance for account #{account.id} with #{balance}")
          Account.set_balance(account, balance)
        {:error, error} ->
          Logger.error("#{__MODULE__}: Received error attempting to update acocunt #{account.id}: #{inspect(error)}")
      end
    end)
    :ok
  end

  def adhoc_refresh() do
    valid_accounts = Account.get_all_accounts() 
    |> Utilities.filter_valid_accounts()
    :ok = do_account_refresh(valid_accounts)
  end
end