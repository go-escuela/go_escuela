defmodule Web.Users.UsersController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  alias GoEscuelaLms.Core.Schema.User

  plug :is_admin_authorized when action in [:create, :index]

  @create_params %{
    full_name: [type: :string, required: true],
    email: [type: :string, required: true],
    role: [type: :string, required: true, in: ~w(student instructor)],
    password: [type: :string, required: true]
  }

  def create(conn, params) do
    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, user} <- create_user(valid_params) do
      render(conn, :create, user)
    end
  end

  def index(conn, _params) do
    render(conn, :index, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end

  defp create_user(params) do
    name = params |> get_in(~w[full_name])

    User.create(%{
      full_name: name,
      email: params |> get_in(~w[email]),
      role: params |> get_in(~w[role]),
      password_hash: generate_password(name)
    })
  end

  defp generate_password(name) do
    year = DateTime.utc_now().year
    name = name |> String.replace(" ", "_")
    "Goescuela_#{name}_#{year}"
  end
end
