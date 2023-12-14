defmodule Web.Topics.TopicsController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.Topic

  plug :is_permit_authorized when action in [:create]
  plug :load_course when action in [:create]
  plug :load_course when action in [:create]
  plug :check_enrollment when action in [:create]

  @create_params %{
    name: [type: :string, required: true]
  }

  def create(conn, params) do
    course = conn.assigns.course

    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, topic} <- create_topic(course, valid_params) do
      render(conn, :create, %{topic: topic})
    end
  end

  defp create_topic(course, params) do
    Topic.create(%{
      name: params |> get_in([:name]),
      course_id: course.uuid
    })
  end
end
