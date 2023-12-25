defmodule Web.Activities.ActivitiesJSON do
  @doc """
  Renders users
  """
  alias GoEscuelaLms.Core.Schema.Activity

  def create(%{activity: activity}) do
    %{
      data: data(activity)
    }
  end

  defp data(%Activity{} = activity) do
    %{
      id: activity.uuid,
      name: activity.name,
      enabled: activity.enabled
    }
  end
end
