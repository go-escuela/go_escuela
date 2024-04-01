defmodule Web.Users.ProfileController do
  use Web, :controller

  action_fallback Web.FallbackController

  alias Core.Schema.User

  @update_params %{
    full_name: :string,
    email: :string,
    password: :string
  }

  def show(conn, _params) do
    render(conn, :show, %{data: conn.assigns.account})
  end

  def update(conn, params) do
    user = conn.assigns.account

    with {:ok, valid_params} <- Tarams.cast(params, @update_params),
         {:ok, user_updated} <- update_user(user, valid_params) do
      render(conn, :update, %{data: user_updated})
    end
  end

  defp update_user(user, params) do
    password = params |> get_in([:password])

    attrs = %{
      full_name: params |> get_in([:full_name]) || user.full_name,
      email: params |> get_in([:email]) || user.email
    }

    attrs =
      case is_nil(password) do
        true ->
          attrs

        _ ->
          attrs |> Map.merge(%{password_hash: password})
      end

    user |> User.update(attrs)
  end
end
