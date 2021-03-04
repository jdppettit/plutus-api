defmodule Plutus.Model.TransactionCategory do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  
  alias Plutus.Repo

  require Logger


  schema "transaction_category" do
    field :remote_id, :integer
    field :categories, :string
    field :category_type, :string
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :remote_id,
      :categories,
      :category_type
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
    case Repo.insert(changeset) do
      {:ok, model} ->
        {:ok, model}

      _ ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def get_by_remote_id(remote_id) do
    case Repo.get_by(__MODULE__, remote_id: remote_id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
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