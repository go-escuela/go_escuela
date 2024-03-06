defmodule Web.Activities.ActivitiesController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.Activity

  plug :permit_authorized when action in [:create]
  plug :load_course when action in [:create]
  plug :check_enrollment when action in [:create]
  plug :load_topic when action in [:create]

  @create_params %{
    name: [type: :string, required: true],
    activity_type: [type: :string, required: true, in: Activity.activity_types()],
    feedback: :string,
    enabled: :boolean
  }

  @quiz_params %{
    start_date: [type: :string, required: true],
    end_date: [type: :string, required: true],
    max_attempts: :integer,
    grade_pass: :float
  }

  def create(conn, params) do
    topic = conn.assigns.topic

    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, valid_params} <- activity_type_valid_params(params, valid_params),
         {:ok, activity} <- create_activity(topic, params, valid_params) do
      render(conn, :create, %{activity: activity})
    end
  end

  defp activity_type_valid_params(params, %{activity_type: activity_type} = valid_params) do
    case activity_type do
      "quiz" ->
        create_params = @create_params |> Map.merge(@quiz_params)

        Tarams.cast(params, create_params)

      _ ->
        if is_nil(params |> get_in(["resource"])) do
          {:error, "file is empty"}
        else
          {:ok, valid_params}
        end
    end
  end

  defp create_activity(topic, params, valid_params) do
    Task.async(fn ->
      activity_type = valid_params |> get_in([:activity_type])

      create_valid_params = %{
        name: valid_params |> get_in([:name]),
        topic_id: topic.uuid,
        activity_type: activity_type,
        feedback: valid_params |> get_in([:feedback]),
        enabled: valid_params |> get_in([:enabled]) || false
      }

      case activity_type do
        "resource" ->
          resource = params |> get_in(["resource"])
          params = create_valid_params |> Map.merge(%{resource: resource})
          Activity.create_with_resource(params)

        _ ->
          params =
            create_valid_params
            |> Map.merge(%{
              start_date: valid_params |> get_in([:start_date]),
              end_date: valid_params |> get_in([:end_date]),
              max_attempts: valid_params |> get_in([:max_attempts]) || 1,
              grade_pass: valid_params |> get_in([:grade_pass]) || 100
            })

          case Activity.create_with_quiz(params) do
            {:error, {:failed, error}} ->
              error

            response ->
              response
          end
      end
    end)
    |> Task.await()
  end
end
