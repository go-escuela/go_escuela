defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update]

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end
end
