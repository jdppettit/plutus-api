defmodule Plutus.Repo.Migrations.SettledByEvent do
  use Ecto.Migration

  def change do
    alter table("event") do
      add :settled_by, :integer
    end
  end
end
