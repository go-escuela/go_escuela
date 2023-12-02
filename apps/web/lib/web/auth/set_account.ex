defmodule Web.Auth.SetAccount do
  @moduledoc """
  module Set user data in conn session
  """

  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.User

  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:account] do
      conn
    else
      user_id = get_session(conn, :user_id)

      if user_id == nil, do: raise(message: "Unauthorized", plug_status: 401)
      account = User.find(user_id)

      cond do
        user_id && account -> assign(conn, :account, account)
        true -> assign(conn, :account, nil)
      end
    end
  end
end
