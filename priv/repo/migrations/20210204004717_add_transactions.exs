defmodule Plutus.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add :description, :string
      add :amount, :float
      add :pending, :boolean
      add :date, :date
      add :remote_id, :string
      add :account_id, :integer

      timestamps()
    end
  end
end
