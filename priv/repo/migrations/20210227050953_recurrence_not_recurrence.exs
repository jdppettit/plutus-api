defmodule Plutus.Repo.Migrations.RecurrenceNotRecurrence do
  use Ecto.Migration

  def change do
    alter table("expense") do
      add :month, :integer
      add :recurring, :boolean
    end

    alter table("income") do
      add :month, :integer
    end
  end
end
