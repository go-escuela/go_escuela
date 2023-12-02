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

      if is_nil(user_id), do: raise(message: "Unauthorized", plug_status: 401)
      account = User.find(user_id)

      case !is_nil(account) do
        true ->
          assign(conn, :account, account)

        _ ->
          assign(conn, :account, nil)
      end
    end
  end
end
