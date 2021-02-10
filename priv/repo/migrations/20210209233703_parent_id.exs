defmodule Plutus.Repo.Migrations.ParentId do
  use Ecto.Migration

  def change do
    alter table("event") do
      add :parent_id, :integer

      timestamps()
    end
  end
end
