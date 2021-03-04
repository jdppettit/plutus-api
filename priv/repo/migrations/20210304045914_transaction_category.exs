defmodule Plutus.Repo.Migrations.TransactionCategory do
  use Ecto.Migration

  def change do
    create table("transaction_category") do
      add :remote_id, :integer
      add :categories, :string
      add :category_type, :string
    end

    create unique_index(:transaction_category, [:remote_id])
  end
end
