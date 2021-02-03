defmodule Plutus.Plaid.Account do
  def exchange_public_token(public_token) do
    Plaid.Item.exchange_public_token(public_token)
  end 
end