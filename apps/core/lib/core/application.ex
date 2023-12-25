defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    credentials = System.get_env("GOOGLE_API_CREDENTIALS") |> Base.decode64!() |> Jason.decode!()

    source = {:service_account, credentials, []}

    children = [
      GoEscuelaLms.Core.Repo,
      {Goth, name: Core.Goth, source: source}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
