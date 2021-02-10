defmodule Plutus.Repo.Migrations.AccountIdEvent do
  use Ecto.Migration

  def change do
    alter table("event") do
      add :account_id, :integer
    end
  end
end
