defmodule Plutus.Model.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  
  alias Plutus.Repo

  require Logger


  schema "transaction" do
    field :description, :string
    field :amount, :float
    field :pending, :boolean
    field :date, :date
    field :remote_id, :string
    field :category_id, :integer

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
    case Plutus.Repo.get_by(__MODULE__, remote_id: map.remote_id) do
      nil ->
        __MODULE__.create_changeset(map)
      model ->
        __MODULE__.create_changeset(model, map)
    end 
  end

  def get_all_transactions_for_account(account_id) do
    query = from transaction in __MODULE__,
      where: transaction.account_id == ^account_id
    case Plutus.Repo.all(query) do
      transactions ->
        {:ok, transactions}
      {:error, error} ->
        Logger.error("#{__MODULE__} Error querying entry record #{inspect(error)}")
        {:error, :not_found}
    end
  end

  def get_by_window(%{account_id: account_id, window_start: window_start, window_end: window_end}) do
    query = from(event in __MODULE__,
      where: event.account_id == ^account_id,
      where: event.date >= ^window_start,
      where: event.date <= ^window_end,
      order_by: [asc: event.date]
    )
    Plutus.Repo.all(query)
  end

  def get_by_remote_id(remote_id) do
  IO.inspect(remote_id, label: "get_by_remote_id")
    case Repo.get_by(__MODULE__, remote_id: remote_id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
    end
  end

  def delete(model) do
    Repo.delete(model)
  end
end