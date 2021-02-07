defmodule Plutus.Repo.Migrations.FixRecurringIncome do
  use Ecto.Migration

  def change do
    alter table("income") do
      remove :reccurring
      add :recurring, :boolean
    end
  end
end
