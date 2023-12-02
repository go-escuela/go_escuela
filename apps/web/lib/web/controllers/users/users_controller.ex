defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  plug :is_authorized_account when action in [:update]

  defp is_authorized_account(conn, _opts) do
    %{params: %{"id" => id}} = conn

    if conn.assigns.account.uuid == id do
      conn
    else
      Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
    end
  end

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end
end
