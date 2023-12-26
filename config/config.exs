# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :web,
  generators: [context_app: :web]

# Configures the endpoint
config :web, Web.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: Web.PubSub,
  live_view: [signing_salt: "Xzp7WliM"],
  server: true

config :core, :ecto_repos, [
  GoEscuelaLms.Core.Repo
]

config :web, :ecto_repos, [
  GoEscuelaLms.Core.Repo
]

config :web, Web.Auth.Guardian,
  issuer: "go_escuela_lms",
  secret_key: System.get_env("SECRET_AUTH_KEY")

config :guardian, Guardian.DB,
  repo: GoEscuelaLms.Core.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 60

config :core,
  bucket: System.get_env("GOOGLE_BUCKET", "bucket")

import_config "#{Mix.env()}.exs"
