defmodule Plutus.Worker.TransactionWorker do
  use GenServer

  alias Plutus.Model.{Account,Transaction}
  alias Plutus.Common.Utilities

  require Logger

  @minus_days -30
  @interval 86_400_000 # 1 day
  @fetch_interval 1_000

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :transaction_worker
    )
  end

  def init(_) do
    Logger.info("#{__MODULE__}: Initializing genserver for transaction processing")
    Process.send_after(self(), :get_transactions, 1_000)
    {:ok, nil}
  end

  def handle_info(:get_transactions, _) do
    Logger.info("#{__MODULE__}: Getting transactions now")
    accounts = Account.get_all_accounts()
    :ok = process_transactions(accounts)
    Process.send_after(self(), :get_transactions, @interval)
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
    case Plaid.Transactions.get(%{
      access_token: account.access_token,
      start_date: one_month_ago(),
      end_date: now(),
      options: %{
        count: count,
        offset: offset
      }
    }) do
      {:ok, tx_data} ->
        tx_data.transactions
        |> filter_for_account(account.remote_id)
        |> persist_transactions(account.id)
        
        new_offset = offset+100

        if tx_data.total_transactions >= count do
          :timer.sleep(@fetch_interval)
          fetch_transactions(account, count, offset + 100)
        end
      {:error, error} ->
        Logger.error("#{__MODULE__}: Got error #{inspect(error)} when fetching transactions for account #{account.id} / #{account.description}")
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
    Logger.info("#{__MODULE__}: Persisting transactions")
    transactions
    |> Enum.map(fn tx -> 
      # This should happen first otherwise our uniqueness check will prevent the non-pending transaction
      # from being persisted

      handle_pending_transaction(tx)
    
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
    pending: pending,
    category_id: category_id
  }, account_id) do
    %{
      description: name,
      amount: amount,
      date: date,
      remote_id: transaction_id,
      account_id: account_id,
      pending: pending,
      category_id: category_id
    }
  end

  def handle_pending_transaction(%{pending_transaction_id: pending_tx_id} = transaction) when not is_nil(pending_tx_id) do
    IO.inspect(pending_tx_id)
    case Transaction.get_by_remote_id(pending_tx_id) do
      {:ok, transaction} ->
        Logger.info("#{__MODULE__}: Transaction #{inspect(transaction.id)} had pending_transaction_id #{inspect(pending_tx_id)} deleting old tx with that remote_id")
        Transaction.delete(transaction)
      {_, _} ->
        Logger.error("#{__MODULE__}: Transaction had pending_transaction_id #{inspect(pending_tx_id)} but we couldn't find a tx with that remote_id")
    end
  end

  def handle_pending_transaction(_transaction) do
    Logger.debug("#{__MODULE__}: Looked at transaction with no pending transaction id")
  end

  def adhoc_process_transactions() do
    valid_accounts = Account.get_all_accounts() 
    |> Utilities.filter_valid_accounts()
    :ok = process_transactions(valid_accounts)
  end
end