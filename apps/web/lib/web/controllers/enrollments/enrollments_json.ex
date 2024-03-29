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

  def delete(%{enrollment: enrollment}) do
    %{message: "enrollment deleted", data: data(enrollment)}
  end

  defp data(%Enrollment{} = enrollment) do
    %{
      id: enrollment.uuid,
      course_id: enrollment.course_id,
      user_id: enrollment.user_id,
      inserted_at: enrollment.inserted_at |> to_string()
    }
  end
end
