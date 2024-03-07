defmodule Web.Activities.ActivitiesJSON do
  @doc """
  Renders users
  """
  alias GoEscuelaLms.Core.Schema.Activity

  def create(%{activity: activity}) do
    case activity |> Activity.resource?() do
      true ->
        %{
          data: data(activity)
        }

      # quizz activity
      _ ->
        %{
          data: data(activity)
        }
    end
  end

  defp data(%Activity{} = activity) do
    %{
      id: activity.uuid,
      name: activity.name,
      enabled: activity.enabled
    }
  end
end
