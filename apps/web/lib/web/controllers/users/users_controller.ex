defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.User

  plug :is_organizer_authorized when action in [:create]
  plug :load_user when action in [:update]

  @create_params %{
    full_name: [type: :string, required: true],
    email: [type: :string, required: true],
    role: [type: :string, required: true, in: User.roles()],
    password: [type: :string, required: true]
  }

  @update_params %{
    full_name: :string,
    email: :string,
    role: [type: :string, in: User.roles()]
  }

  def create(conn, params) do
    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, user} <- create_user(valid_params) do
      render(conn, :create, %{user: user})
    end
  end

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, params) do
    user = conn.assigns.user

    with {:ok, valid_params} <- Tarams.cast(params, @update_params),
         {:ok, user_updated} <- update_user(user, valid_params) do
      render(conn, :update, %{user: user_updated})
    end
  end

  defp update_user(user, params) do
    user
    |> User.update(%{
      full_name: params |> get_in([:full_name]),
      email: params |> get_in([:email]),
      role: params |> get_in([:role])
    })
  end

  defp create_user(params) do
    User.create(%{
      full_name: params |> get_in([:full_name]),
      email: params |> get_in([:email]),
      role: params |> get_in([:role]),
      password_hash: params |> get_in([:password])
    })
  end
end
