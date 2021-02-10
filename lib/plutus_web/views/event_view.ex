defmodule PlutusWeb.EventView do
  use PlutusWeb, :view

  def render("expense_created.json", %{event: event}) do
    %{
      message: "event created successfully",
      event: %{id: event.id}
    }
  end

  def render("events.json", %{events: events}) do
    parsed_events = events
    |> Enum.map(fn event -> 
      %{
        id: event.id,
        description: event.description,
        amount: event.amount,
        type: event.type,
        settled: event.settled,
        anticipated_date: event.anticipated_date,
        parent_id: event.parent_id
      }
    end)
    %{
      message: "events retrieved successfully",
      events: parsed_events
    }
  end

  def render("event.json", %{event: event}) do
    %{
      message: "event retrieved successfully",
      event: %{
        id: event.id,
        description: event.description,
        amount: event.amount,
        type: event.type,
        settled: event.settled,
        anticipated_date: event.anticipated_date,
        parent_id: event.parent_id
      }
    }
  end

  def render("bad_request.json", %{message: message}) do
    %{
      message: message
    }
  end
end