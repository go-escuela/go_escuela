defmodule Web.Users.ProfileController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    render(conn, :show, %{data: conn.assigns.account})
  end
end
