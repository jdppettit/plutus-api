defmodule Plutus.Repo.Migrations.AddAccountName do
  use Ecto.Migration

  def change do
    alter table("account") do
      add :account_name, :string
    end 
  end
end
