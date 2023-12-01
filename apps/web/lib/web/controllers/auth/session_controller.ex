defmodule Web.Auth.SessionController do
  use Web, :controller

  alias Web.Auth.Guardian

  action_fallback Web.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        render(conn, :create, %{account: account, token: token})
      error ->
        error
    end
  end
end
