defmodule Web.Home.PageController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    render(conn, :show, %{status: :ok})
  end
end
