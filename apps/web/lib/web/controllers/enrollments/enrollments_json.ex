defmodule Web.Enrollments.EnrollmentsJSON do
  @doc """
  Renders enrollments
  """

  def create(%{enrollment: enrollment}) do
    %{
      data: %{
        id: enrollment.id,
        enrollment_id: enrollment.uuid,
        inserted_at: enrollment.inserted_at
      }
    }
  end
end
