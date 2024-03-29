defmodule Web.EnrollmentsControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  alias GoEscuelaLms.Core.Schema.Enrollment

  setup do
    course = insert!(:course)
    user = insert!(:user, role: :instructor)
    organizer = insert!(:user, role: :organizer)

    {:ok, user: user, organizer: organizer, course: course}
  end

  describe "index/2" do
    test "list enrollments by course", %{user: user, organizer: organizer, course: course} do
      user1 = insert!(:user, role: :instructor)
      user2 = insert!(:user, role: :student)

      enrollment1 = insert!(:enrollment, course_id: course.uuid, user_id: user1.uuid)
      enrollment2 = insert!(:enrollment, course_id: course.uuid, user_id: user2.uuid)

      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/courses/#{course.uuid}/enrollments")

      response = json_response(conn, 200)["data"]

      assert response == [
               %{
                 "id" => enrollment1.uuid,
                 "course_id" => enrollment1.course_id,
                 "user_id" => enrollment1.user_id,
                 "inserted_at" => enrollment1.inserted_at |> to_string()
               },
               %{
                 "id" => enrollment2.uuid,
                 "course_id" => enrollment2.course_id,
                 "user_id" => enrollment2.user_id,
                 "inserted_at" => enrollment2.inserted_at |> to_string()
               }
             ]
    end

    test "list enrollments by current user", %{user: user} do
      course1 = insert!(:course)
      course2 = insert!(:course)

      enrollment1 = insert!(:enrollment, course_id: course1.uuid, user_id: user.uuid)
      enrollment2 = insert!(:enrollment, course_id: course2.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/enrollments")

      response = json_response(conn, 200)["data"]

      assert response == [
               %{
                 "id" => enrollment1.uuid,
                 "course_id" => enrollment1.course_id,
                 "user_id" => enrollment1.user_id,
                 "inserted_at" => enrollment1.inserted_at |> to_string()
               },
               %{
                 "id" => enrollment2.uuid,
                 "course_id" => enrollment2.course_id,
                 "user_id" => enrollment2.user_id,
                 "inserted_at" => enrollment2.inserted_at |> to_string()
               }
             ]
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
        |> post(~p"/api/enrollments", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "with invalid course", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/enrollments", %{course_id: Faker.UUID.v4()})

      assert json_response(conn, 422)["errors"] == %{"detail" => "course is invalid"}
    end

    test "with invalid user", %{organizer: organizer, course: course} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/enrollments", %{course_id: course.uuid, user_id: Faker.UUID.v4()})

      assert json_response(conn, 422)["errors"] == %{"detail" => "user is invalid"}
    end

    test "valid create", %{user: user, organizer: organizer, course: course} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/enrollments", %{course_id: course.uuid, user_id: user.uuid})

      response = json_response(conn, 200)["data"]
      assert response["course_id"] == course.uuid
      assert response["user_id"] == user.uuid
      assert is_nil(response["id"]) == false
      assert is_nil(response["inserted_at"]) == false
    end
  end

  describe "delete/2" do
    test "unauthorized", %{user: user} do
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/enrollments")

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "with invalid enrollment", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/enrollments/#{Faker.UUID.v4()}")

      assert json_response(conn, 422)["errors"] == %{"detail" => "enrollment is invalid"}
    end

    test "valid delete", %{organizer: organizer, course: course, user: user} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      enrollment = insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/enrollments/#{enrollment.uuid}")

      assert json_response(conn, 200)
      assert Enrollment.find(enrollment.uuid) == nil
    end
  end
end
