defmodule Plutus.Repo.Migrations.AccountSettings do
  use Ecto.Migration

  def change do
    AccountType.create_type

    alter table("account") do
      add :balance_to_maintain, :float, default: 0.00
      add :type, AccountType.type()
      add :include_in_overall, :boolean, default: true
    end
  end
end
