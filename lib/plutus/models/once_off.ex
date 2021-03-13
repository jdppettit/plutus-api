defmodule Plutus.Model.OnceOff do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plutus.Repo
  alias Plutus.Common.Date, as: PDate
  
  require Logger

  schema "once_off" do
    field :anticipated_date, :date
    field :settled, :boolean
    field :amount, :float
    field :description, :string
    field :account_id, :integer
    field :settled_by, :integer
    field :transaction_description, :string
    field :auto_settle, :boolean, default: true

    timestamps()
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :amount,
      :description,
      :auto_settle,
      :account_id,
      :anticipated_date
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

  def create(map) do
    {:ok, changeset} = __MODULE__.create_changeset(map)
    __MODULE__.insert(changeset)
  end

  def get_by_id(id) do
    case Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model |> wrap_in_type}
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

  def wrap_in_type(model) when is_map(model) do
    Map.put(model, :type, :once_off)
  end

  def wrap_in_type(models) when is_list(models) do
    models
    |> Enum.map(&wrap_in_type(&1))
  end
end