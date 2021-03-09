defmodule Plutus.Repo.Migrations.AutoSettleEvent do
  use Ecto.Migration

  def change do
    alter table("event") do
      add :auto_settle, :boolean, default: true
    end
  end
end
