defmodule Plutus.Model.Expense do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plutus.Repo
  
  require Logger

  schema "expense" do
    field :amount, :float
    field :description, :string
    field :transaction_description, :string
    field :recurring, :boolean
    field :month, :integer

    timestamps()

    belongs_to :income, Plutus.Model.Income
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :amount,
      :description,
      :transaction_description
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

  def update_expense(map) do
    {:ok, model} = get_by_id(map.id)
    {:ok, changeset} = create_changeset(model, map)
    Repo.update(changeset)
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

  def get_all_expenses_for_income(income_id) do
    query = from expense in __MODULE__,
      where: expense.income_id == ^income_id
    case Plutus.Repo.all(query) do
      expenses ->
        {:ok, expenses}
      {:error, error} ->
        Logger.error("#{__MODULE__} Error querying entry record #{inspect(error)}")
        {:error, :not_found}
    end
  end
end