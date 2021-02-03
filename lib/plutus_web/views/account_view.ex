defmodule PlutusWeb.AccountView do
  use PlutusWeb, :view

  def render("link_token.json", %{link_token: link_token}) do
    %{
      message: "link token created",
      linkToken: link_token
    }
  end

  def render("account_created.json", %{account: account}) do
    %{
      message: "account created",
      account: %{
        id: account.id
      }
    }
  end

  def render("bad_request.json", message) do
    %{
      message: message
    }
  end

  def render("account.json", %{account: account}) do
    %{
      message: "account get success",
      account: %{
        id: account.id,
        public_token: account.public_token,
        access_token: account.access_token
      }
    }
  end
end