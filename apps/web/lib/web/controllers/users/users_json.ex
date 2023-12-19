defmodule Web.Users.UsersJSON do
  @doc """
  Renders users
  """

  def index(%{}) do
    %{data: %{}}
  end

  def create(%{user: user}) do
    %{data: %{email: user.email, full_name: user.full_name}}
  end

  def update(%{user: user}) do
    %{data: %{email: user.email, full_name: user.full_name}}
  end
end
