defmodule Web.Enrollments.EnrollmentsController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  alias GoEscuelaLms.Core.Schema.{Course, Enrollment, User}

  plug :is_organizer_authorized when action in [:create]

  def create(conn, params) do
    user_id = params["users_id"]
    course_id = params["courses_id"]

    with :ok <- valid_uuids(user_id),
         :ok <- valid_uuids(course_id),
         :ok <- valid_resources(user_id, course_id),
         {:ok, enrollment} <- create_enrollment(user_id, course_id) do
      render(conn, :create, %{enrollment: enrollment})
    end
  end

  defp create_enrollment(user_id, course_id) do
    Enrollment.create(%{
      course_id: course_id,
      user_id: user_id
    })
  end

  defp valid_uuids(id) do
    case Ecto.UUID.dump(id) do
      {:ok, _} ->
        :ok

      _ ->
        {:error, "invalid params"}
    end
  end

  def valid_resources(user_id, course_id) do
    with false <- is_nil(Course.find(course_id)),
         false <- is_nil(User.find(user_id)) do
      :ok
    else
      _ ->
        {:error, "Resource does not exist"}
    end
  end
end
