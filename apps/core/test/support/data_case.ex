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
  by setting `use AuthService.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  defmacro __using__(_module) do
    quote location: :keep do
      using do
        quote do
          alias GoEscuelaLms.Core.Repo

          import Ecto
          import Ecto.Changeset
          import Ecto.Query
          import Core.DataCase
        end
      end

      setup tags do
        :ok = Sandbox.checkout(GoEscuelaLms.Core.Repo)

        unless tags[:async] do
          Sandbox.mode(GoEscuelaLms.Core.Repo, {:shared, self()})
        end

        :ok
      end
    end
  end
end
