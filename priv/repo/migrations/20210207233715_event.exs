defmodule Plutus.Repo.Migrations.Event do
  use Ecto.Migration

  def change do
    EventType.create_type

    create table("event") do
      add :target_id, :integer
      add :type, EventType.type()
      add :anticipated_date, :date
      add :settled, :boolean
      add :precompute_date, :date
      add :amount, :float
      add :previous_target_id, :integer
      add :description, :string
    end
  end
end
