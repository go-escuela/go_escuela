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

  defp data(%User{} = user) do
    %{
      email: user.email,
      full_name: user.full_name
    }
  end
end
