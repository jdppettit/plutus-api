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

    post "/income", IncomeController, :create
    get "/income", IncomeController, :get_all
    get "/income/:id", IncomeController, :get

    get "/account/linktoken", AccountController, :link_token
    post "/account", AccountController, :create
    get "/account/:id", AccountController, :get

    scope "/expense", PlutusWeb do

    end

    scope "/transaction", PlutusWeb do

    end
  end
end
