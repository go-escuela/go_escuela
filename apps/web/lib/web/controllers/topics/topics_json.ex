defmodule Web.Topics.TopicsJSON do
  @doc """
  Renders topic
  """

  def create(%{topic: topic}) do
    %{data: %{name: topic.name}}
  end
end
