use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :strabo, Strabo.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :strabo, Strabo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "strabo_test",
  password: "password",
  database: "strabo_test",
  size: 1,
  max_overflow: false,
  pool: Ecto.Adapters.SQL.Sandbox
