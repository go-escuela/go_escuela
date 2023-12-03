defmodule Web.Auth.SessionController do
  use Web, :controller

  alias Web.Auth.Guardian

  action_fallback Web.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        conn
        |> put_session(:user_id, account.uuid)
        |> render(:create, %{account: account, token: token})

      error ->
        error
    end
  end

  def refresh_session(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    {:ok, account, new_token} = Guardian.authenticate(token)

    conn
    |> put_session(:user_id, account.uuid)
    |> render(:create, %{account: account, token: new_token})
  end

  def destroy(conn, _params) do
    account = conn.assigns[:account]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> render(:destroy, %{account: account, token: nil})
  end
end
