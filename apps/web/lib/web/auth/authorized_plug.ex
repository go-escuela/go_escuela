defmodule Web.Auth.AuthorizedPlug do
  @moduledoc """
  This module plug authorized
  """
  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.User

  # def is_authorized(%{params: %{"id" => id}} = conn, _opts) do
  #   if conn.assigns.account.uuid == id do
  #     conn
  #   else
  #     Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
  #   end
  # end

  def is_admin_authorized(conn, _) do
    case conn.assigns.account |> User.organizer?() do
      true ->
        conn

      _ ->
        Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
    end
  end

  def is_instructor_authorized(conn, _) do
    case conn.assigns.account |> User.instructor?() do
      true ->
        conn

      _ ->
        Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
    end
  end
end
