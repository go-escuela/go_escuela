defmodule Web.Users.UsersJSON do
  @doc """
  Renders users
  """

  def create(%{user: user}) do
    %{data: %{email: user.email}}
  end

  def index(%{}) do
    %{data: %{}}
  end

  def update(%{}) do
    %{data: %{}}
  end
end
