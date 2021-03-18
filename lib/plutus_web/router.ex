defmodule PlutusWeb.Router do
  use PlutusWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", PlutusWeb do
    pipe_through(:api)

   
    get "/account/linktoken", AccountController, :link_token
    post "/account", AccountController, :create
    put "/account/:id", AccountController, :update
    post "/account/exchange", AccountController, :exchange
    get "/account/:id", AccountController, :get
    get "/account", AccountController, :get_all

    get "/account/:account_id/transaction", TransactionController, :get_all
    get "/account/:account_id/transaction/window", TransactionController, :get_by_window
    get "/account/:account_id/transaction/:id", TransactionController, :get

    post "/account/:account_id/once_off", OnceOffController, :create
    get "/account/:account_id/once_off", OnceOffController, :get_all

    post "/account/:account_id/income", IncomeController, :create
    get "/account/:account_id/income", IncomeController, :get_all
    get "/account/:account_id/income/:id", IncomeController, :get
    delete "/account/:account_id/income/:id", IncomeController, :delete

    post "/account/:account_id/income/:income_id/expense", ExpenseController, :create
    get "/account/:account_id/income/:income_id/expense", ExpenseController, :get_all
    get "/account/:account_id/income/:income_id/expense/:id", ExpenseController, :get
    put "/account/:account_id/income/:income_id/expense/:id", ExpenseController, :update

    get "/account/:account_id/event/income/current", EventController, :get_current_income
    get "/account/:account_id/event", EventController, :get_by_window
    post "/account/:account_id/event", EventController, :create
    put "/account/:account_id/event/:id", EventController, :update
    delete "/account/:account_id/event/:id", EventController, :delete

    get "/update_balances", AccountController, :update_balances
    get "/precompute", EventController, :precompute
    get "/settlement", EventController, :settlement
    get "/update_transactions", TransactionController, :update_transactions
    get "/match", EventController, :match
    get "/refresh_data", EventController, :refresh_data
  end
end
