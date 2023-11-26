import Config

config :core, GoEscuelaLms.Core.Repo,
  url: System.get_env("DATABASE_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 2
