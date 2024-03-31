defmodule Web.Users.UsersJSON do
  @doc """
  Renders users
  """

  alias GoEscuelaLms.Core.Schema.User

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def create(%{user: user}) do
    %{data: data(user)}
  end

  def update(%{user: user}) do
    %{data: data(user)}
  end

  def delete(%{user: user}) do
    %{message: "user deleted", data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.uuid,
      email: user.email,
      role: user.role,
      full_name: user.full_name,
      inserted_at: user.inserted_at |> to_string()
    }
  end
end
