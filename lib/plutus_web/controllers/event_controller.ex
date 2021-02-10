defmodule PlutusWeb.EventController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.{Event,Account}
  alias Plutus.Worker.PrecomputeWorker
  alias PlutusWeb.Params.{AccountId, ExpenseId, IncomeId, StringDate}

  require Logger

  defparams(
    get_window_params(%{
      account_id!: AccountId,
      window_start!: StringDate,
      window_end!: StringDate
    })
  )

  def get_by_window(conn, raw_params) do
    with {:validation, %{valid?: true} = params_changeset} <- {:validation, get_window_params(raw_params) |> IO.inspect},
         parsed_params <- Params.to_map(params_changeset),
         events <- Event.get_by_window(parsed_params) do
      conn
      |> render("events.json", events: events)
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

  def precompute(conn, _params) do
    with :ok <- PrecomputeWorker.adhoc_precompute() do
      conn
      |> render("precompute.json", message: "precompute running")
    else 
      _ ->
        conn
        |> put_status(500)
        |> render("bad_request.json", message: "precompute fail")      
    end
  end

  def filter_valid_accounts(accounts) do
    accounts
    |> Enum.filter(fn account -> 
      !is_nil(Map.get(account, :access_token, nil))
    end)
  end
end 