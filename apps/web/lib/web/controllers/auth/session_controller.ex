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
    old_token = Guardian.Plug.current_token(conn)

    with {:ok, claims} <- Guardian.decode_and_verify(old_token),
         {:ok, account} <- Guardian.resource_from_claims(claims),
         {:ok, _old, {new_token, _new_claims}} <- Guardian.refresh(old_token) do
      conn
      |> Plug.Conn.put_session(:account_id, account.uuid)
      |> render(:create, %{account: account, token: new_token})
    else
      _ ->
        Web.FallbackController.call(conn, {:error, :not_found}) |> halt()
    end
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
