defmodule Web.Courses.CoursesJSON do
  @doc """
  Renders users
  """

  def create(%{course: course}) do
    %{data: %{name: course.name, enabled: course.enabled, description: course.description}}
  end

  def index(%{}) do
    %{data: %{}}
  end

  def update(%{}) do
    %{data: %{}}
  end
end
