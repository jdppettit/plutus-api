defmodule PlutusWeb.AccountController do
  use PlutusWeb, :controller

  require Logger

  def link_token(conn, _params) do
    {:ok, response} = Plaid.Link.create_link_token(%{
      client_name: "Demo",
      language: "en",
      country_codes: ["US"],
      products: ["auth", "transactions"],
      user: %{
        client_user_id: "1"
      }
    })
    IO.inspect(response)
    conn
    |> put_status(200)
    |> render("link_token.json", link_token: response.link_token)
  end
end