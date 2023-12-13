defmodule Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Web, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"403")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"422", error: Ecto.Changeset.traverse_errors(changeset, &translate_error/1))
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(422)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"422", error: error)
  end

  def call(conn, error) do
    conn
    |> put_status(500)
    |> put_view(json: Web.ErrorJSON)
    |> render(:"500", error: error)
  end

  defp translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    case opts[:count] do
      nil ->
        Gettext.dgettext(Web.Gettext, "errors", msg, opts)

      count ->
        Gettext.dngettext(Web.Gettext, "errors", msg, msg, count, opts)
    end
  end
end
