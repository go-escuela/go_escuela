defmodule Web.Enrollments.EnrollmentsJSON do
  @doc """
  Renders enrollments
  """

  alias GoEscuelaLms.Core.Schema.Enrollment

  def index(%{enrollments: enrollments}) do
    %{data: for(enrollment <- enrollments, do: data(enrollment))}
  end

  def create(%{enrollment: enrollment}) do
    %{
      data: data(enrollment)
    }
  end

  defp data(%Enrollment{} = enrollment) do
    %{
      id: enrollment.uuid,
      enrollment_id: enrollment.uuid,
      inserted_at: enrollment.inserted_at
    }
  end
end
