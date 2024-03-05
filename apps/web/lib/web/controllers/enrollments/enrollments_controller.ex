defmodule Web.Enrollments.EnrollmentsController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.{Enrollment}

  plug :permit_authorized when action in [:index, :create]
  plug :load_user when action in [:create]
  plug :load_course when action in [:create, :index]

  def index(conn, _params) do
    course = conn.assigns.course
    render(conn, :index, %{enrollments: course.enrollments})
  end

  def create(conn, _params) do
    course = conn.assigns.course
    user = conn.assigns.user

    case create_enrollment(user, course) do
      {:ok, enrollment} ->
        render(conn, :create, %{enrollment: enrollment})
    end
  end

  defp create_enrollment(user, course) do
    Enrollment.create(%{
      course_id: course.uuid,
      user_id: user.uuid
    })
  end
end
