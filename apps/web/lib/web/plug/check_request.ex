defmodule Web.Plug.CheckRequest do
  @moduledoc """
  This module plug check request and load resource
  """
  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.Enrollment
  alias GoEscuelaLms.Core.Schema.{Course, Enrollment, Topic, User}

  def load_user(conn, _) do
    id = conn.params["id"] || conn.params["users_id"] || conn.params["user_id"]

    with :ok <- valid_uuids(id),
         object <- User.find(id),
         false <- is_nil(object) do
      assign(conn, :user, object)
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "user is invalid"}) |> halt()
    end
  end

  def load_course(conn, _) do
    course_id = conn.params["id"] || conn.params["courses_id"] || conn.params["course_id"]

    with :ok <- valid_uuids(course_id),
         course <- Course.find(course_id),
         false <- is_nil(course) do
      assign(conn, :course, course)
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "course is invalid"}) |> halt()
    end
  end

  def load_topic(conn, _) do
    id = conn.params["id"] || conn.params["topics_id"]

    with :ok <- valid_uuids(id),
         object <- Topic.find(id),
         false <- is_nil(object) do
      assign(conn, :topic, object)
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "topic is invalid"}) |> halt()
    end
  end

  def load_enrollment(conn, _) do
    id = conn.params["id"]

    with :ok <- valid_uuids(id),
         object <- Enrollment.find(id),
         false <- is_nil(object) do
      assign(conn, :enrollment, object)
    else
      _ ->
        Web.FallbackController.call(conn, {:error, "enrollment is invalid"}) |> halt()
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

  defp valid_uuids(id) do
    case Ecto.UUID.dump(id) do
      {:ok, _} ->
        :ok

      _ ->
        {:error, "invalid params"}
    end
  end
end
