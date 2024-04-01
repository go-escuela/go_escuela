defmodule Core.Repo do
  @moduledoc """
  DATABASE repo
  """

  use Ecto.Repo,
    otp_app: :core,
    adapter: Ecto.Adapters.Postgres
end
