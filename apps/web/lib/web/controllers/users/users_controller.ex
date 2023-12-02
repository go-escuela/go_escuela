defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, _params) do
    render(conn, :index, %{})
  end
end
