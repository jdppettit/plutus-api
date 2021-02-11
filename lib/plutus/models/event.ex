defmodule Plutus.Model.Event do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plutus.Repo
  alias Plutus.Common.Date, as: PDate
  
  require Logger

  schema "event" do
    field :target_id, :integer
    field :type, EventType
    field :anticipated_date, :date
    field :settled, :boolean
    field :precompute_date, :date
    field :amount, :float
    field :previous_target_id, :integer
    field :description, :string
    field :parent_id, :integer
    field :account_id, :integer

    timestamps()
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :amount,
      :description,
      :target_id,
      :type,
      :precompute_date
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

  def get_by_id(id) do
    case Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
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

  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, model} ->
        {:ok, model}

      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def guess_and_create_changeset(map) do
    case Plutus.Repo.get_by(__MODULE__, 
      [target_id: map.target_id, type: map.type, precompute_date: map.precompute_date]
    ) do
      nil ->
        __MODULE__.create_changeset(map)
      model ->
        __MODULE__.create_changeset(model, map)
    end 
  end

  def maybe_insert(%{type: :income} = map) do
    model = Plutus.Repo.get_by(__MODULE__, 
      [target_id: map.target_id, type: map.type, anticipated_date: map.anticipated_date]
    )
    if is_nil(model) do
      {:ok, changeset} = __MODULE__.create_changeset(map)
      {:ok, model} = Repo.insert_or_update(changeset)
    else
      {:ok, model}
    end
  end

  def maybe_insert(%{type: :expense} = map) do
    model = Plutus.Repo.get_by(__MODULE__, 
      [target_id: map.target_id, type: map.type, parent_id: map.parent_id]
    )
    if is_nil(model) do
      {:ok, changeset} = __MODULE__.create_changeset(map)
      {:ok, model} = Repo.insert_or_update(changeset)
    else
      {:ok, model}
    end
  end

  def get_by_window(%{account_id: account_id, window_start: window_start, window_end: window_end}) do
    query = from(event in __MODULE__,
      where: event.account_id == ^account_id,
      where: event.anticipated_date >= ^window_start,
      where: event.anticipated_date <= ^window_end,
      order_by: [asc: event.anticipated_date]
    )
    Plutus.Repo.all(query)
  end
end