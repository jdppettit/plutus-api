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

    scope "/income", PlutusWeb do
      post "/", IncomeController, :create
      get "/", IncomeController, :get_all
      get "/:id", IncomeController, :get
    end

    scope "/account", PlutusWeb do

    end

    scope "/expense", PlutusWeb do

    end

    scope "/transaction", PlutusWeb do

    end
  end
end
