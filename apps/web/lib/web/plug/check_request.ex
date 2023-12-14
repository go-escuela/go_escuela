defmodule Web.Plug.CheckRequest do
  @moduledoc """
  This module plug check request and load resource
  """
  import Plug.Conn
  alias GoEscuelaLms.Core.Schema.{Course}

  def load_course(conn, _) do
    course_id = conn.params["courses_id"]

    IO.puts "COURSE_ID ==> #{course_id}"

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
    with {:ok, _} <- Ecto.UUID.dump(id) do
      :ok
    else
      _ ->
        {:error, "invalid params"}
    end
  end
end
