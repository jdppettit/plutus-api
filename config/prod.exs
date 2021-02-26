use Mix.Config

config :plutus, PlutusWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "replaceme.com", port: {:system, "PORT"}],
  https: [
    port: 8043,
    otp_app: :plutus,
    keyfile: "../../../../certs/key.pem",
    certfile: "../../../../certs/cert.pem",
    cacertfile: "../../../../certs/chain.pem"
  ],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]]

config :plutus, Plutus.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "plutus_prod",
  password: "replaceme",
  database: "plutus_prod",
  hostname: "replaceme",
  pool_size: 5,
  port: 25060,
  ssl: true

config :logger, backends: [:console, Gelfx]

config :logger, Gelfx,
  host: "graylog.pettit.home",
  hostname: "plutus-api-production",
  level: :info
  

config :plutus, PlutusWeb.Endpoint,
  secret_key_base: "qwJjb8u4Ypi90spfvkYxp4I5l4javEs/GUTavUDZSOipUfhA+Xxpqcijr7fqsWX4"