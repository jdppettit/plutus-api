defmodule Plutus.Repo.Migrations.TransactionCategoryModel do
  use Ecto.Migration

  def change do
    alter table("transaction") do
      add :category_id, :integer
    end
  end
end
