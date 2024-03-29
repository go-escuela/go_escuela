defmodule Web.Enrollments.EnrollmentsController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.{Course, Enrollment}

  plug :organizer_authorized when action in [:create, :delete]
  plug :load_course when action in [:create]
  plug :load_user when action in [:create]
  plug :load_enrollment when action in [:delete]

  @create_params %{
    course_id: [type: :string, required: true],
    user_id: [type: :string, required: true]
  }

  def index(conn, %{"courses_id" => course_id}) do
    with course <- Course.find(course_id),
         false <- is_nil(course) do
      render(conn, :index, %{enrollments: course.enrollments})
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "course is invalid"}) |> halt()
    end
  end

  def index(conn, _params) do
    user = conn.assigns.account
    render(conn, :index, %{enrollments: user.enrollments})
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
