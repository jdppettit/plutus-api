defmodule Plutus.Model.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "transaction" do
    field :description, :string
    field :amount, :float
    field :pending, :boolean
    field :date, :date
    field :remote_id, :string

    timestamps()

    belongs_to :account, Plutus.Model.Account
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :description,
      :amount,
      :pending,
      :date,
      :remote_id
    ])
    |> unique_constraint(:remote_id)
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

  def insert(changeset) do
    case Plutus.Repo.insert(changeset) do
      {:ok, model} ->
        {:ok, model}

      _ ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def guess_and_create_changeset(map) do
    case Plutus.Repo.get_by(__MODULE__, remote_id: map.remote_id) do
      nil ->
        __MODULE__.create_changeset(map)
      model ->
        __MODULE__.create_changeset(model, map)
    end 
  end
end