defmodule Web.Auth.SetAccount do
  @moduledoc """
  module Set user data in conn session
  """

  import Plug.Conn
  alias Core.Schema.User

  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:account] do
      conn
    else
      user_id = get_session(conn, :user_id)

      with false <- is_nil(user_id),
           account <- User.find(user_id),
           false <- is_nil(account) do
        assign(conn, :account, account)
      else
        _ ->
          assign(conn, :account, nil)
          Web.FallbackController.call(conn, {:error, :unauthorized}) |> halt()
      end
    end
  end
end
