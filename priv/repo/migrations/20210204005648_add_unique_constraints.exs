defmodule Plutus.Repo.Migrations.AddUniqueConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:account, [:remote_id])
    create unique_index(:transaction, [:remote_id])
  end
end
