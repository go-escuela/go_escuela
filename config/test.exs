import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "t2MLXkDJ2CQ91+yN67qU+nuBSqT94xgK9KcYmrUvpmQEoeE5CGlcvf5y33+NucED",
  server: false

config :core, GoEscuelaLms.Core.Repo,
  url: System.get_env("TEST_DATABASE_URL"),
  pool: Ecto.Adapters.SQL.Sandbox
