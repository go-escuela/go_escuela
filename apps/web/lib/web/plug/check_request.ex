defmodule Web.Plug.CheckRequest do
  @moduledoc """
  This module plug check request and load resource
  """
  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.{Course}

  def load_course(conn, _) do
    course_id = conn.params["courses_id"]

    with :ok <- valid_uuids(course_id),
         course <- Course.find(course_id),
         false <- is_nil(course) do
      assign(conn, :course, course)
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "invalid params"}) |> halt()
    end
  end

  defp valid_uuids(id) do
    case Ecto.UUID.dump(id) do
      {:ok, _} ->
        :ok

      _ ->
        {:error, "invalid params"}
    end
  end

  def check_enrollment(%{assigns: %{account: %{role: :organizer}}} = conn, _), do: conn

  def check_enrollment(conn, _) do
    user_id = conn.assigns.account.uuid
    course = conn.assigns.course

    case is_nil(
           course.enrollments
           |> Enum.find(fn enrollment -> enrollment.user_id == user_id end)
         ) do
      false ->
        conn

      _ ->
        Web.FallbackController.call(conn, {:error, :forbidden}) |> halt()
    end
  end
end
