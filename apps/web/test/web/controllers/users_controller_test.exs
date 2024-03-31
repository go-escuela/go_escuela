defmodule Web.UsersControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  setup do
    instructor = insert!(:user, role: :instructor)
    organizer = insert!(:user, role: :organizer)

    {:ok, instructor: instructor, organizer: organizer}
  end

  describe "create/2" do
    test "unauthorized", %{instructor: instructor} do
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/users", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid params", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/users", %{})

      assert json_response(conn, 422)["errors"] == %{
               "detail" => %{
                 "email" => ["is required"],
                 "full_name" => ["is required"],
                 "password" => ["is required"],
                 "role" => ["is required"]
               }
             }
    end

    test "valid params", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      user =
        build(:user)
        |> Map.from_struct()
        |> Map.merge(%{role: "student", password: Faker.String.base64(100)})

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/users", user)

      response = json_response(conn, 200)["data"]

      assert response["full_name"] == user.full_name
      assert response["email"] == user.email
      assert response["role"] == user.role
    end
  end

  describe "index/2" do
    test "unauthorized", %{instructor: instructor} do
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/users", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "get all users", %{instructor: instructor, organizer: organizer} do
      student = insert!(:user, role: :student)

      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/users")

      response = json_response(conn, 200)["data"]

      assert response == [
               %{
                 "id" => instructor.uuid,
                 "full_name" => instructor.full_name,
                 "email" => instructor.email,
                 "role" => instructor.role |> to_string(),
                 "inserted_at" => instructor.inserted_at |> to_string()
               },
               %{
                 "id" => organizer.uuid,
                 "full_name" => organizer.full_name,
                 "email" => organizer.email,
                 "role" => organizer.role |> to_string(),
                 "inserted_at" => organizer.inserted_at |> to_string()
               },
               %{
                 "id" => student.uuid,
                 "full_name" => student.full_name,
                 "email" => student.email,
                 "role" => student.role |> to_string(),
                 "inserted_at" => student.inserted_at |> to_string()
               }
             ]
    end
  end
end
