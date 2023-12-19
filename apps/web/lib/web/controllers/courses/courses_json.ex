defmodule Web.Courses.CoursesJSON do
  @doc """
  Renders users
  """

  def create(%{course: course}) do
    %{
      data: %{
        id: course.uuid,
        name: course.name,
        enabled: course.enabled,
        description: course.description
      }
    }
  end

  def index(%{}) do
    %{data: %{}}
  end

  def update(%{}) do
    %{data: %{}}
  end
end
