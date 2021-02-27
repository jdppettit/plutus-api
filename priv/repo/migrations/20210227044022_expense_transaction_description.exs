defmodule Plutus.Repo.Migrations.ExpenseTransactionDescription do
  use Ecto.Migration

  def change do
    alter table("expense") do
      add :transaction_description, :string
    end
  end
end
