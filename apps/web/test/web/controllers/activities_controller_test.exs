defmodule Web.ActivitiesControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory
  import Mock

  alias Core.GCP.Manager, as: GCPManager

  setup do
    course = insert!(:course)
    topic = insert!(:topic, course_id: course.uuid)

    {:ok, course: course, topic: topic}
  end

  describe "create/2" do
    test "unauthorized with student user", %{course: course, topic: topic} do
      user = insert!(:user, role: :student)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", %{})

      assert json_response(conn, 403)
    end

    test "with invalid course", %{course: _course, topic: topic} do
      user = insert!(:user, role: :instructor)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{Faker.UUID.v4()}/topics/#{topic.uuid}/activities", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "course is invalid"}
    end

    test "with invalid topic", %{course: course, topic: _topic} do
      user = insert!(:user, role: :instructor)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{Faker.UUID.v4()}/activities", %{})

      assert json_response(conn, 422)["errors"] == %{"detail" => "topic is invalid"}
    end

    test "without enrollment to course", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", %{})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden resource"}
    end

    test "create resource with invalid params", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      activity =
        build(:activity, activity_type: "resource", topic_id: topic.uuid)
        |> Map.from_struct()

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", activity)

      assert json_response(conn, 422) == %{"errors" => %{"detail" => "file is empty"}}
    end

    test "valid create resource", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      file = %Plug.Upload{path: "test/fixtures/example.txt", filename: "example.txt"}

      activity =
        build(:activity, activity_type: "resource", topic_id: topic.uuid)
        |> Map.from_struct()
        |> Map.merge(%{resource: file})

      with_mocks [
        {GCPManager, [:passthrough], upload: fn _, _ -> {:ok, "resource"} end}
      ] do
        conn =
          session_conn()
          |> put_session(:user_id, user.uuid)
          |> put_req_header("accept", "application/json")
          |> put_req_header("authorization", "Bearer " <> token)
          |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", activity)

        response = json_response(conn, 200)["data"]

        assert response["enabled"] == true
        assert is_nil(response["id"]) == false
        assert response["name"] == activity[:name]
      end
    end

    test "create quiz with invalid params", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      activity =
        build(:activity, activity_type: "quiz", topic_id: topic.uuid, questions: [%{}])
        |> Map.from_struct()

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", activity)

      assert json_response(conn, 422)
    end

    test "valid create quiz", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      questions = [
        %{
          mark: 10.0,
          description: nil,
          title: Faker.Lorem.sentence(),
          uuid: nil,
          feedback: nil,
          question_type: "multiple_choice",
          answers: [
            %{
              description: Faker.Lorem.sentence(),
              match_answer: nil,
              feedback: nil,
              correct_answer: true
            }
          ]
        }
      ]

      activity =
        build(:activity, activity_type: "quiz", topic_id: topic.uuid, questions: questions)
        |> Map.from_struct()

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", activity)

      response = json_response(conn, 200)["data"]

      assert response["enabled"] == true
      assert is_nil(response["id"]) == false
      assert response["name"] == activity[:name]
    end

    test "valid create quiz with ", %{course: course, topic: topic} do
      user = insert!(:user, role: :instructor)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      questions = [
        %{
          mark: 10.0,
          description: "la respuesta de la primera variable {{name}} y la segunda {{variable2}}",
          title: Faker.Lorem.sentence(),
          uuid: nil,
          feedback: nil,
          question_type: "matching",
          answers: [
            %{
              description: "name",
              match_answer: "Nicolas",
              feedback: nil,
              correct_answer: true
            },
            %{
              description: "variable2",
              match_answer: "pepe",
              feedback: nil,
              correct_answer: true
            }
          ]
        }
      ]

      activity =
        build(:activity, activity_type: "quiz", topic_id: topic.uuid, questions: questions)
        |> Map.from_struct()

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", activity)

      response = json_response(conn, 200)["data"]

      assert response["enabled"] == true
      assert is_nil(response["id"]) == false
      assert response["name"] == activity[:name]
    end
  end
end
