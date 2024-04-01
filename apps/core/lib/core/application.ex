defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      Application.get_env(:core, :environment)
      |> children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:common) do
    [
      Core.Repo
    ]
  end

  defp children(:test), do: children(:common)

  defp children(_) do
    credentials = System.get_env("GOOGLE_API_CREDENTIALS") |> Base.decode64!() |> Jason.decode!()
    source = {:service_account, credentials, []}

    children(:common) ++ [{Goth, name: Core.Goth, source: source}]
  end
end
