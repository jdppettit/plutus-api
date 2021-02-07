defmodule Plutus.Common.Model do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plutus.Repo

  require Logger

  defmacro __using__(opts) do
    module = Keyword.get(opts, :module)
    struct = Keyword.get(opts, :struct)

    quote do
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
    end
  end
end