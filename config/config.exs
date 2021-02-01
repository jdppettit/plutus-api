use Mix.Config

config :plutus,
  ecto_repos: [Plutus.Repo]

# Configures the endpoint
config :plutus, PlutusWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IrLXoGMvCJagrb8qkMW5XdE1VELQBFLy88C4LQZZv6rWxVXLGm20W7dydMX+BVvW",
  render_errors: [view: PlutusWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Plutus.PubSub,
  live_view: [signing_salt: "3JJF9rau"]

config :phoenix, :format_encoders,
  json: Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
import_config "secret.exs"
