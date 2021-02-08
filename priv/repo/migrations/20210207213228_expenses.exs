defmodule Plutus.Repo.Migrations.Expenses do
  use Ecto.Migration

  def change do
    create table("expense") do
      add :amount, :float
      add :description, :string
      add :income_id, :integer

      timestamps()
    end
  end
end
