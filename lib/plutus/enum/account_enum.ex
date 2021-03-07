defmodule AccountType do
  use EctoEnum,
    type: :account_type,
    enums: [
      :depository,
      :credit,
      :loan,
      :other
    ]
end