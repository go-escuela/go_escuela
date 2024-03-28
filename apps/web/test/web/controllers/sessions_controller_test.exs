defmodule Web.SessionsControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  alias GoEscuelaLms.Core.Schema.User

  describe "create/2" do
    test "invalid credentials", %{conn: conn} do
      user = insert!(:user, role: :instructor)

      conn =
        conn
        |> post(~p"/api/auth/sessions", %{"email" => user.email, "password" => Faker.UUID.v4()})

      assert json_response(conn, 401)
    end

    test "valid session", %{conn: conn} do
      password = Faker.UUID.v4()

      {:ok, user} =
        build(:user)
        |> Map.from_struct()
        |> Map.merge(%{password_hash: password})
        |> User.create()

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> post(~p"/api/auth/sessions", %{"email" => user.email, "password" => password})

      assert json_response(conn, 200)
    end
  end

  describe "refresh_session/2" do
    test "invalid credentials", %{conn: _conn} do
      user = insert!(:user, role: :instructor)

      {:ok, _token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> Faker.UUID.v4())
        |> get(~p"/api/auth/sessions")

      assert json_response(conn, 401)
    end

    test "valid refresh session", %{conn: _conn} do
      user = insert!(:user, role: :student)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/auth/sessions")

      assert json_response(conn, 200)
    end
  end

  describe "destroy/2" do
    test "invalid credentials", %{conn: _conn} do
      user = insert!(:user, role: :instructor)

      {:ok, _token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> Faker.UUID.v4())
        |> delete(~p"/api/auth/sessions")

      assert json_response(conn, 401)
    end

    test "valid refresh session", %{conn: _conn} do
      user = insert!(:user, role: :student)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/auth/sessions")

      assert json_response(conn, 200)
    end
  end
end
