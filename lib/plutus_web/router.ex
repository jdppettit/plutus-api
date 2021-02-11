defmodule PlutusWeb.Router do
  use PlutusWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", PlutusWeb do
    pipe_through(:api)

    get "/account/linktoken", AccountController, :link_token
    post "/account", AccountController, :create
    get "/account/:id", AccountController, :get
    get "/account", AccountController, :get_all

    get "/account/:account_id/transaction", TransactionController, :get_all
    get "/account/:account_id/transaction/window", TransactionController, :get_by_window
    get "/account/:account_id/transaction/:id", TransactionController, :get

    post "/account/:account_id/income", IncomeController, :create
    get "/account/:account_id/income", IncomeController, :get_all
    get "/account/:account_id/income/:id", IncomeController, :get

    post "/account/:account_id/income/:income_id/expense", ExpenseController, :create
    get "/account/:account_id/income/:income_id/expense", ExpenseController, :get_all
    get "/account/:account_id/income/:income_id/expense/:id", ExpenseController, :get

    get "/account/:account_id/event", EventController, :get_by_window
    get "/precompute", EventController, :precompute
  end
end
