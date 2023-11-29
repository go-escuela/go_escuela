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
  live_view: [signing_salt: "Xzp7WliM"]

config :core, :ecto_repos, [
  GoEscuelaLms.Core.Repo
]

config :web, Web.Auth.Guardian,
  issuer: "go_escuela_lms",
  secret_key: "zZcHgx8qMuX9xXV2r1CN2hTI4Zc0Qre3MH08dnHVxf1NSmyxCyEbeFpP83f3urKL"

import_config "#{Mix.env()}.exs"
