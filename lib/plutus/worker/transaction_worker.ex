defmodule Plutus.Worker.TransactionWorker do
  use GenServer

  alias Plutus.Model.{Account,Transaction}

  require Logger

  @minus_days -30
  @interval 86_400_000 # 1 day

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :transaction_worker
    )
  end

  def init(_) do
    Logger.debug("#{__MODULE__}: Initializing genserver for transaction processing")
    Process.send_after(self(), :get_transactions, 1_000)
    {:ok, nil}
  end

  def handle_info(:get_transactions, _) do
    Logger.debug("#{__MODULE__}: Getting transactions now")
    accounts = Account.get_all_accounts()
    :ok = process_transactions(accounts)
    Process.send_after(self(), :get_transactions, 10_000)
    {:noreply, nil}
  end

  def process_transactions(accounts) do
    accounts
    |> Enum.map(fn account ->
      if not is_nil(Map.get(account, :access_token, nil)) do
        fetch_transactions(account, 100, 0)
      else
        Logger.warn("#{__MODULE__}: Account #{account.id} had no access token, skipping")
      end
    end)
    :ok
  end

  def fetch_transactions(account, count, offset) do
    {:ok, tx_data} = Plaid.Transactions.get(%{
      access_token: account.access_token,
      start_date: one_month_ago(),
      end_date: now(),
      options: %{
        count: count,
        offset: offset
      }
    })

    tx_data.transactions
    |> filter_for_account(account.remote_id)
    |> persist_transactions(account.id)
    
    new_offset = offset+100

    if tx_data.total_transactions == offset do
      fetch_transactions(account, count + 100, offset + 100)
    end
  end

  def now() do
    Date.utc_today()
    |> Date.to_string()
  end

  def one_month_ago() do
    now = Date.utc_today()
    Date.add(now, @minus_days)
    |> Date.to_string()
  end

  def filter_for_account(transactions, account_id) do
    transactions
    |> Enum.filter(fn tx ->
      tx.account_id == account_id
    end)
  end

  def persist_transactions(transactions, account_id) do
    transactions
    |> Enum.map(fn tx -> 
      formatted_tx = format_transaction(tx, account_id)
      {:ok, changeset} = Transaction.guess_and_create_changeset(formatted_tx)
      Plutus.Repo.insert_or_update(changeset)
    end)
  end

  def format_transaction(%{
    amount: amount,
    transaction_id: transaction_id,
    date: date,
    name: name,
    pending: pending
  }, account_id) do
    %{
      description: name,
      amount: amount,
      date: date,
      remote_id: transaction_id,
      account_id: account_id,
      pending: pending
    }
  end
end