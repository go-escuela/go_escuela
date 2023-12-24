defmodule Web.Courses.CoursesController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.{Course, User}

  plug :is_organizer_authorized when action in [:create, :update]
  plug :load_course when action in [:show, :update]
  plug :check_enrollment when action in [:show, :update]

  @create_params %{
    name: [type: :string, required: true],
    description: :string,
    enabled: [type: :boolean, default: false]
  }

  @update_params %{
    name: :string,
    description: :string,
    enabled: :boolean
  }

  def show(conn, _params) do
    render(conn, :show, %{data: conn.assigns.course})
  end

  def create(conn, params) do
    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, course} <- create_course(valid_params) do
      render(conn, :create, %{course: course})
    end
  end

  def update(conn, params) do
    course = conn.assigns.course

    with {:ok, valid_params} <- Tarams.cast(params, @update_params),
         {:ok, course_updated} <- update_course(course, valid_params) do
      render(conn, :update, %{course: course_updated})
    end
  end

  def index(conn, _params) do
    data =
      cond do
        conn.assigns.account |> User.organizer?() ->
          Course.all()

        conn.assigns.account |> User.instructor?() ->
          Course.all(conn.assigns.account.uuid)
      end

    render(conn, :index, %{courses: data})
  end

  defp create_course(params) do
    Course.create(%{
      name: params |> get_in([:name]),
      description: params |> get_in([:description]),
      enabled: params |> get_in([:enabled])
    })
  end

  defp update_course(course, params) do
    course
    |> Course.update(%{
      name: params |> get_in([:name]),
      description: params |> get_in([:description]),
      enabled: params |> get_in([:enabled])
    })
  end
end
