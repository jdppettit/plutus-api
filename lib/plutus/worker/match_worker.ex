defmodule Plutus.Worker.MatchWorker do
  use GenServer

  alias Plutus.Model.{Account,Income,Expense,Event, Transaction}
  alias Plutus.Types.Precompute
  alias Plutus.Common.Date, as: PDate
  alias Plutus.Common.Utilities

  require Logger

  @interval 86_400_000 # 1 day

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :match_worker
    )
  end

  def init(_) do
    Logger.info("#{__MODULE__}: Initializing genserver for match processing")
    Process.send_after(self(), :match, 1_000)
    {:ok, nil}
  end

  def handle_info(:match, _) do
    Logger.info("#{__MODULE__}: Starting match now")
    valid_accounts = Account.get_all_accounts() 
    |> Utilities.filter_valid_accounts()
    :ok = do_match(valid_accounts)
    Process.send_after(self(), :match, @interval)
    {:noreply, nil}
  end

  def do_match(accounts) do
    accounts
    |> Enum.map(fn account ->
      Logger.info("#{__MODULE__}: Starting match for account #{account.id}")
      {:ok, current_income} = Event.get_current_income_event(account.id)
      if not is_nil(current_income) do
        {:ok, expenses_for_income} = Event.get_expenses_for_income(current_income.id)
        transactions = Transaction.get_by_window(%{
            account_id: current_income.account_id, 
            window_start: PDate.get_beginning_of_month(), 
            window_end: PDate.get_current_date()
          }
        )
        match_expense_to_transaction(expenses_for_income, transactions)
      end
    end)
    :ok
  end

  def match_expense_to_transaction(expenses, transactions) do
    expenses
    |> Enum.map(fn expense ->
      transactions
      |> Enum.map(fn transaction ->
        if not is_nil(Map.get(expense, :transaction_description, nil)) do
          if expense.amount == transaction.amount && 
             String.downcase(expense.transaction_description) == String.downcase(transaction.description)
          do
            Logger.info("#{__MODULE__}: Setting expense #{expense.id} to settled based on transaction #{transaction.id}")
            Event.set_settled(expense, transaction.id)
          end
        else
          if expense.amount == transaction.amount && 
            String.downcase(expense.transaction_description) == String.downcase(transaction.description) 
          do
            Logger.info("#{__MODULE__}: Setting expense #{expense.id} to settled based on transaction #{transaction.id}")
            Event.set_settled(expense, transaction.id)
          else
            if not is_nil(Map.get(expense, :transaction_description, nil)) && String.contains?(transaction.description, expense.transaction_description) do
              Logger.info("#{__MODULE__}: Setting expense #{expense.id} to settled based on transaction #{transaction.id}")
              Event.set_settled(expense, transaction.id)
            end
          end
        end
      end)
    end)
  end

  def adhoc_match() do
    valid_accounts = Account.get_all_accounts() 
    |> Utilities.filter_valid_accounts()
    :ok = do_match(valid_accounts)
  end
end