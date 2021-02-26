defmodule Plutus.Plaid.Account do
  def exchange_public_token(public_token) do
    case Plaid.Item.exchange_public_token(public_token) do
      {:ok, data} ->
        {:ok, data}
      {:error, error} ->
        {:error, error, nil}
    end
  end 
end