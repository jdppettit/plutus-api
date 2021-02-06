defmodule Plutus.Repo.Migrations.AddIncome do
  use Ecto.Migration

  def change do
    create table("income") do 
      add :reccurring, :boolean
      add :day_of_month, :integer
      add :day_of_week, :integer
      add :amount, :float
      add :description, :string
      add :account_id, :integer

      timestamps()
    end
  end
end
