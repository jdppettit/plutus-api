defmodule Plutus.Model.Income do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plutus.Repo

  require Logger


  schema "income" do
    field :recurring, :boolean
    field :day_of_month, :integer
    field :day_of_week, :integer
    field :amount, :float
    field :description, :string

    timestamps()

    belongs_to :account, Plutus.Model.Account
    has_many :expenses, Plutus.Model.Expense
  end

  def changeset(income, attrs) do
    income
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :recurring,
      :amount,
      :description
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

  def delete_by_id(id) do
    model = get_by_id(id)
    case Repo.delete(model) do
      {:ok, _struct} ->
        {:ok, nil}
      {:error, _} ->
        {:error, :database_error}
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

  def get_all_income_for_account(account_id) do
    query = from income in __MODULE__,
      where: income.account_id == ^account_id
    case Plutus.Repo.all(query) do
      income ->
        {:ok, income}
      {:error, error} ->
        Logger.error("#{__MODULE__} Error querying entry record #{inspect(error)}")
        {:error, :not_found}
    end
  end
end