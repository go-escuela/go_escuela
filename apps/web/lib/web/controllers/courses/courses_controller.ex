defmodule Web.Courses.CoursesController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  alias GoEscuelaLms.Core.Schema.Course

  plug :is_organizer_authorized when action in [:create]

  @create_params %{
    name: [type: :string, required: true],
    description: :string,
    enabled: [type: :boolean, default: false]
  }

  def create(conn, params) do
    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, course} <- create_course(valid_params) do
      render(conn, :create, %{course: course})
    end
  end

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end

  defp create_course(params) do
    Course.create(%{
      name: params |> get_in([:name]),
      description: params |> get_in([:description]),
      enabled: params |> get_in([:enabled])
    })
  end
end
