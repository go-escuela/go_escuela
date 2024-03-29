defmodule Web.CoursesControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  setup do
    user = insert!(:user, role: :instructor)
    organizer = insert!(:user, role: :organizer)

    {:ok, user: user, organizer: organizer}
  end

  describe "show/2" do
    test "invalid course", %{user: user} do
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses/#{Faker.UUID.v4()}")

      assert json_response(conn, 422)["errors"] == %{"detail" => "course is invalid"}
    end

    test "invalid enrollment", %{user: user} do
      course = insert!(:course)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses/#{course.uuid}")

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "display course", %{user: user} do
      course = insert!(:course)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses/#{course.uuid}")

      assert json_response(conn, 200)["data"] == %{
               "description" => course.description,
               "enabled" => true,
               "id" => course.uuid,
               "name" => course.name,
               "topics" => []
             }
    end
  end

  describe "create/2" do
    test "unauthorized", %{user: user} do
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "create with invalid params", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => %{"name" => ["is required"]}}
    end

    test "create with valid params", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      course = build(:course) |> Map.from_struct()

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses", course)

      response = json_response(conn, 200)["data"]

      assert response["enabled"] == true
      assert response["description"] == course[:description]
      assert is_nil(response["id"]) == false
      assert response["name"] == course[:name]
    end
  end

  describe "update/2" do
    test "unauthorized", %{user: user} do
      course = insert!(:course)
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/courses/#{course.uuid}", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid course", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/courses/#{Faker.UUID.v4()}", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "course is invalid"}
    end

    test "update invalid params", %{organizer: organizer} do
      course = insert!(:course)
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/courses/#{course.uuid}", %{name: nil})

      assert json_response(conn, 422)["errors"] == %{"detail" => %{"name" => ["can't be blank"]}}
    end

    test "update valid params", %{organizer: organizer} do
      course = insert!(:course)
      new_name = Faker.Lorem.word()
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/courses/#{course.uuid}", %{name: new_name})

      response = json_response(conn, 200)["data"]
      assert response["name"] == new_name
    end
  end

  describe "index/2" do
    test "organizer access all courses", %{organizer: organizer} do
      course1 = insert!(:course)
      course2 = insert!(:course)

      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses")

      response = json_response(conn, 200)["data"]

      assert response == [
               %{
                 "description" => course1.description,
                 "enabled" => course1.enabled,
                 "id" => course1.uuid,
                 "name" => course1.name
               },
               %{
                 "description" => course2.description,
                 "enabled" => course2.enabled,
                 "id" => course2.uuid,
                 "name" => course2.name
               }
             ]
    end

    test "instructor show enrollment courses", %{user: user} do
      course1 = insert!(:course)
      insert!(:course)
      insert!(:course)

      insert!(:enrollment, course_id: course1.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses")

      response = json_response(conn, 200)["data"]

      assert response == [
               %{
                 "description" => course1.description,
                 "enabled" => course1.enabled,
                 "id" => course1.uuid,
                 "name" => course1.name
               }
             ]
    end
  end
end
