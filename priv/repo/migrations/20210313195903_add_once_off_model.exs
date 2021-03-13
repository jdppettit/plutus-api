defmodule Plutus.Repo.Migrations.AddOnceOffModel do
  use Ecto.Migration

  def change do
    create table("once_off") do
      add :anticipated_date, :date
      add :settled, :boolean
      add :amount, :float
      add :description, :string
      add :account_id, :integer
      add :settled_by, :integer
      add :transaction_description, :string
      add :auto_settle, :boolean, default: true

      timestamps()
    end
  end
end
