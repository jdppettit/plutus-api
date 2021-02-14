defmodule Plutus.Worker.AccountWorker do
  use GenServer

  alias Plutus.Model.{Account}
  alias Plutus.Common.Date, as: PDate

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
    valid_accounts = Account.get_all_accounts() |> filter_valid_accounts()
    :ok = do_account_refresh(valid_accounts)
    Process.send_after(self(), :account_refresh, @interval)
    {:noreply, nil}
  end

  def do_account_refresh(accounts) do
    accounts
    |> Enum.map(fn account -> 
      {:ok, plaid_data} = Plaid.Accounts.get_balance(%{
        access_token: account.access_token, 
        options: %{account_ids: [account.remote_id]}}
      )
      [first_account | _] = plaid_data.accounts
      balance = first_account.balances.available
      Logger.info("#{__MODULE__}: Updating balance for account #{account.id} with #{balance}")
      Account.set_balance(account, balance)
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