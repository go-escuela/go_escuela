defmodule Web.Topics.TopicsJSON do
  @doc """
  Renders topic
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
    %{name: topic.name}
  end
end
