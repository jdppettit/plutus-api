defmodule PlutusWeb.OnceOffView do
  use PlutusWeb, :view

  def render("once_off_created.json", %{once_off: once_off}) do
    %{
      message: "once off created successfully",
      once_off: %{
        anticipated_date: once_off.anticipated_date,
        settled: once_off.settled,
        amount: once_off.amount,
        description: once_off.description,
        account_id: once_off.account_id,
        settled_by: once_off.settled_by,
        transaction_description: once_off.transaction_description,
        auto_settle: once_off.auto_settle
      }
    }
  end

  def render("bad_request.json", %{message: message}) do
    %{
      message: message
    }
  end
end