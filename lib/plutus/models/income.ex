defmodule Plutus.Model.Income do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
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
end