defmodule Web.Courses.CoursesJSON do
  @doc """
  Renders users
  """
  alias GoEscuelaLms.Core.Schema.Course

  def show(%{course: course}) do
    %{
      data:
        data(course) |> Map.merge(%{topics: for(topic <- course.topics, do: topic_data(topic))})
    }
  end

  def create(%{course: course}) do
    %{
      data: data(course)
    }
  end

  def update(%{course: course}) do
    %{
      data: data(course)
    }
  end

  def index(%{courses: courses}) do
    %{data: for(course <- courses, do: data(course))}
  end

  defp data(%Course{} = course) do
    %{
      id: course.uuid,
      name: course.name,
      enabled: course.enabled,
      description: course.description
    }
  end

  defp topic_data(topic) do
    %{
      id: topic.uuid,
      name: topic.name
    }
  end
end
