defmodule EventType do
  use EctoEnum,
    type: :event_type,
    enums: [
      :income,
      :expense
    ]
end