defmodule PlutusWeb.TransactionController do
  use PlutusWeb, :controller
  use Params

  alias Plutus.Model.Transaction
  alias PlutusWeb.Params.{AccountId, TransactionId}

  defparams(
    get_all_params(%{
      account_id!: AccountId
    })
  )

  def get_all(conn, raw_params) do
    conn
  end

  defparams(
    get_params(%{
      account_id!: AccountId,
      id!: TransactionId
    })
  )

  def get(conn, raw_params) do
    conn
  end
end 
