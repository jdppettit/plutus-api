defmodule Plutus.Repo.Migrations.Accounts do
  use Ecto.Migration

  def change do
    create table("account") do
      add :description, :string
      add :last_four, :integer
      add :remote_id, :string
      add :balance, :float
      add :public_token, :string
      add :access_token, :string
      add :last_refreshed, :utc_datetime

      timestamps()
    end
  end
end
