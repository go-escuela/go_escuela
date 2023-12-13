defmodule Web.Enrollments.EnrollmentsJSON do
  @doc """
  Renders users
  """

  def create(%{enrollment: enrollment}) do
    %{data: %{enrollment_id: enrollment.uuid, inserted_at: enrollment.inserted_at}}
  end
end
