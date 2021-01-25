defmodule PlutusWeb.Router do
  use PlutusWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", PlutusWeb do
    pipe_through(:api)
  end
end
