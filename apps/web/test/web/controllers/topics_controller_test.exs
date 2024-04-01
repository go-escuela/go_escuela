defmodule Web.TopicsControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  alias Core.Schema.Topic

  setup do
    course = insert!(:course)
    student = insert!(:user, role: :student)
    instructor = insert!(:user, role: :instructor)
    organizer = insert!(:user, role: :organizer)

    {:ok, student: student, instructor: instructor, organizer: organizer, course: course}
  end

  describe "create/2" do
    test "unauthorized", %{student: student, course: course} do
      {:ok, token, _} = encode_and_sign(student, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, student.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid course", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{Faker.UUID.v4()}/topics", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "course is invalid"}
    end

    test "invalid enrollment", %{instructor: instructor, course: course} do
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid params", %{instructor: instructor, course: course} do
      insert!(:enrollment, course_id: course.uuid, user_id: instructor.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics", %{name: nil})

      assert json_response(conn, 422)["errors"] == %{"detail" => %{"name" => ["is required"]}}
    end

    test "valid params", %{instructor: instructor, course: course} do
      insert!(:enrollment, course_id: course.uuid, user_id: instructor.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      name = Faker.Lorem.word()

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics", %{name: name})

      response = json_response(conn, 200)["data"]

      assert response["name"] == name
      assert is_nil(response["id"]) == false
    end
  end

  describe "update/2" do
    test "unauthorized", %{student: student, course: course} do
      topic = insert!(:topic, course_id: course.uuid)

      {:ok, token, _} = encode_and_sign(student, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, student.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/topics/#{topic.uuid}", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid topic", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/topics/#{Faker.UUID.v4()}", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "topic is invalid"}
    end

    test "invalid enrollment", %{instructor: instructor, course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/topics/#{topic.uuid}", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid params", %{instructor: instructor, course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      insert!(:enrollment, course_id: course.uuid, user_id: instructor.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/topics/#{topic.uuid}", %{name: nil})

      assert json_response(conn, 422)["errors"] == %{"detail" => %{"name" => ["is required"]}}
    end

    test "valid params", %{instructor: instructor, course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      insert!(:enrollment, course_id: course.uuid, user_id: instructor.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      name = Faker.Lorem.word()

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> put(~p"/api/topics/#{topic.uuid}", %{name: name})

      response = json_response(conn, 200)["data"]

      assert response["name"] == name
      assert is_nil(response["id"]) == false
    end
  end

  describe "delete/2" do
    test "unauthorized", %{student: student, course: course} do
      topic = insert!(:topic, course_id: course.uuid)

      {:ok, token, _} = encode_and_sign(student, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, student.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/topics/#{topic.uuid}", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "invalid topic", %{organizer: organizer} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/topics/#{Faker.UUID.v4()}", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "topic is invalid"}
    end

    test "invalid enrollment", %{instructor: instructor, course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/topics/#{topic.uuid}", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "valid delete", %{instructor: instructor, course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      insert!(:enrollment, course_id: course.uuid, user_id: instructor.uuid)
      {:ok, token, _} = encode_and_sign(instructor, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, instructor.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(~p"/api/topics/#{topic.uuid}")

      assert json_response(conn, 200)
      assert Topic.find(topic.uuid) == nil
    end
  end
end
