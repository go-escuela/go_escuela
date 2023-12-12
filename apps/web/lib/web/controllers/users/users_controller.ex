defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  plug :is_admin_authorized when action in [:create, :index]

  def create(conn, _params) do
    render(conn, :create, %{})
  end

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end
end
