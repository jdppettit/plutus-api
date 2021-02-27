defmodule Plutus.Repo.Migrations.TransactionDescriptionPassthrough do
  use Ecto.Migration

  def change do
    alter table("event") do
      add :transaction_description, :string
    end
  end
end
