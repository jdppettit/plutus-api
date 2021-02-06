defmodule PlutusWeb.Router do
  use PlutusWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", PlutusWeb do
    pipe_through(:api)

    post "/account/:account_id/income", IncomeController, :create
    get "/account/:account_id/income", IncomeController, :get_all
    get "/account/:account_id/income/:id", IncomeController, :get

    get "/account/linktoken", AccountController, :link_token
    post "/account", AccountController, :create
    get "/account/:id", AccountController, :get
    get "/account", AccountController, :get_all

    get "/account/:account_id/transaction", TransactionController, :get_all
    get "/account/:account_id/transaction/:id", TransactionController, :get
  end
end
