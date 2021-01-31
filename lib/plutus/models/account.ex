defmodule Plutus.Model.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Loggers

  schema "account" do
    field :description, :string
    field :last_four, :integer
    field :remote_id, :string
    field :balance, :float

    has_many :transactions, Plutus.Model.Transaction
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :remote_id,
      :balance
    ])
  end

  def create_changeset(map) do
    changeset = __MODULE__.changeset(%__MODULE__{}, map) 
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def create_changeset(model, map) do
    changeset = __MODULE__.changeset(model, map)
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end
end