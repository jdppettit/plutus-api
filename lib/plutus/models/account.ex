defmodule Plutus.Model.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "account" do
    field :description, :string
    field :last_four, :integer
    field :remote_id, :string
    field :balance, :float
    field :public_token, :string
    field :access_token, :string
    field :last_refreshed, :date
    field :account_name, :string

    timestamps()

    has_many :transactions, Plutus.Model.Transaction
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :public_token,
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

  def update(changeset) do
    case Plutus.Repo.update(changeset) do
      {:ok, model} ->
        {:ok, model}

      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def get_by_id(id) do
    case Plutus.Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
    end
  end

  def get_all_accounts() do
    Plutus.Repo.all(__MODULE__)
  end
end