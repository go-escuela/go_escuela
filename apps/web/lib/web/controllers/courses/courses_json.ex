defmodule Web.Courses.CoursesJSON do
  @doc """
  Renders users
  """

  alias GoEscuelaLms.Core.Schema.Course

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
end
