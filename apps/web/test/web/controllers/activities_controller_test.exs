defmodule Web.ActivitiesControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  setup do
    course = insert!(:course)
    topic = insert!(:topic, course_id: course.uuid)

    {:ok, course: course, topic: topic}
  end

  describe "create/2" do
    test "unauthorized with student user", %{conn: _conn, course: course, topic: topic} do
      user = insert!(:user, role: :student)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      IO.puts("TEN ==> #{inspect(token)}")

      conn =
        session_conn()
        |> put_session(:user_id, user.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/courses/#{course.uuid}/topics/#{topic.uuid}/activities", %{})

      assert json_response(conn, 403)
    end
  end
end
