defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  alias GoEscuelaLms.Core.Schema.User

  plug :is_organizer_authorized when action in [:create]

  @create_params %{
    full_name: [type: :string, required: true],
    email: [type: :string, required: true],
    role: [type: :string, required: true, in: User.roles()],
    password: [type: :string, required: true]
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

  def update(conn, _params) do
    render(conn, :update, %{})
  end

  defp create_user(params) do
    name = params |> get_in([:full_name])

    User.create(%{
      full_name: name,
      email: params |> get_in([:email]),
      role: params |> get_in([:role]),
      password_hash: params |> get_in([:password])
    })
  end
end
