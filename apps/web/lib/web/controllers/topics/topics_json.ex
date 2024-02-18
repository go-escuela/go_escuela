defmodule Web.Topics.TopicsJSON do
  @doc """
  Renders topics
  """

  alias GoEscuelaLms.Core.Schema.Topic

  def create(%{topic: topic}) do
    %{data: data(topic)}
  end

  def update(%{topic: topic}) do
    %{data: data(topic)}
  end

  def delete(%{topic: topic}) do
    %{message: "topic deleted", data: data(topic)}
  end

  defp data(%Topic{} = topic) do
    %{
      id: topic.uuid,
      name: topic.name
    }
  end
end
