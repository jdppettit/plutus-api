defmodule PlutusWeb.AccountView do
  use PlutusWeb, :view

  def render("link_token.json", %{link_token: link_token}) do
    %{
      message: "link token created",
      linkToken: link_token
    }
  end
end