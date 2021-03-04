defmodule Plutus.Plaid.Categories do
  alias Plutus.Model.TransactionCategory

  require Logger

  def seed_categories() do
    {:ok, categories} = Plaid.Categories.get
    categories.categories
    |> Enum.map(fn category -> 
      category = Map.from_struct(category)
      |> Map.put(:remote_id, category.category_id)
      |> Map.put(:categories, inspect(category.hierarchy))
      |> Map.put(:category_type, category.group)
      
      {:ok, changeset} = TransactionCategory.guess_and_create_changeset(Map.put(category, :remote_id, category.category_id)) |> IO.inspect(label: "changeset")
      Plutus.Repo.insert_or_update(changeset)

      Logger.info("#{__MODULE__}: Writing category #{inspect(category.category_id)} to database")
    end)
  end
end