defmodule Web.Enrollments.EnrollmentsController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.{Enrollment}

  plug :permit_authorized when action in [:index, :create]
  plug :load_user when action in [:create]
  plug :load_course when action in [:create, :index]
  plug :load_enrollment when action in [:delete]

  @create_params %{
    course_id: [type: :string, required: true],
    user_id: [type: :string, required: true]
  }

  def index(conn, _params) do
    course = conn.assigns.course
    render(conn, :index, %{enrollments: course.enrollments})
  end

  def create(conn, params) do
    course = conn.assigns.course
    user = conn.assigns.user

    with {:ok, _valid_params} <- Tarams.cast(params, @create_params),
         {:ok, enrollment} <- create_enrollment(user, course) do
      render(conn, :create, %{enrollment: enrollment})
    end
  end

  def delete(conn, _params) do
    enrollment = conn.assigns.enrollment

    case enrollment |> Enrollment.delete() do
      {:ok, enrollment} ->
        render(conn, :delete, %{enrollment: enrollment})
    end
  end

  defp create_enrollment(user, course) do
    Enrollment.create(%{
      course_id: course.uuid,
      user_id: user.uuid
    })
  end
end
