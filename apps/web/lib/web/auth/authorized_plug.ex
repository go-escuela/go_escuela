defmodule Web.Auth.AuthorizedPlug do
  @moduledoc """
  This module plug authorized
  """

  def is_authorized(%{params: %{"id" => id}} = conn, _opts) do
    if conn.assigns.account.uuid == id do
      conn
    else
      Web.FallbackController.call(conn, {:error, :forbidden})
    end
  end
end
