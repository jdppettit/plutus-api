defmodule PlutusWeb.OnceOffController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.OnceOff
  alias PlutusWeb.Params.{AccountId,StringDate} 

  defparams(
    create_params(%{
      account_id!: AccountId,
      anticipated_date: StringDate,
      settled: :boolean,
      amount!: :float,
      description!: :string,
      transaction_description: :string,
      auto_settle: :boolean,
      settled_by: :integer
    })
  )

  def create(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, create_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, model} <- OnceOff.create(parsed_params) 
    do
      conn
      |> render("once_off_created.json", once_off: model)
    else
      {:validation, changeset} ->
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
    })
  )

  def get_all(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_all_params(raw_params)},
         parsed_params <- Params.to_map(params_changeset),
         {:ok, models} <- OnceOff.get_all_once_off_for_account(parsed_params) 
    do
      conn
      |> render("once_offs.json", once_offs: models)
    else
      {:validation, changeset} ->
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
