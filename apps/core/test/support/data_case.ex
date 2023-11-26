defmodule Core.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SupervisorService.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Core.DataCase
    end
  end

  @app Mix.Project.config()[:app]

  setup tags do
    for repo <- Application.get_env(@app, :ecto_repos) do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)
    end

    unless tags[:async] do
      for repo <- Application.get_env(@app, :ecto_repos) do
        # :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)
        Sandbox.mode(repo, {:shared, self()})
      end
    end

    :ok
  end
end
