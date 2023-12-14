defmodule Web.Auth.AuthorizedPlug do
  @moduledoc """
  This module plug authorized
  """
  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.User

  def is_organizer_authorized(conn, _) do
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

  def is_permit_authorized(conn, _) do
    case conn.assigns.account |> User.instructor?() || conn.assigns.account |> User.organizer?() do
      true ->
        conn

      _ ->
        Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
    end
  end
end
