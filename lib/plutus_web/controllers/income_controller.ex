defmodule PlutusWeb.IncomeController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Income
  alias PlutusWeb.Params.{AccountId, IncomeId}

  require Logger

  defparams(
    create_params(%{
      account_id!: AccountId,
      recurring: :boolean,
      day_of_month: :integer,
      day_of_week: :integer,
      amount: :float,
      description!: :string
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, changeset} <- Income.create_changeset(parsed_params),
         {:ok, model} <- Income.insert(changeset) do
      conn
      |> render("income_created.json", income: model)
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")
    end
  end

  defparams(
    get_all_params(%{
      account_id!: AccountId,
      id!: TransactionId
    })
  )

  def get_all(conn, raw_params) do 
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset) do
      conn
    else
      {:validation, _} ->
        conn
        |> put_status(400)
        |> render("bad_request.json", message: "bad request")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "database error")
    end
  end
end 