defmodule Web.Auth.SessionJSON do
  @doc """
  Renders a single user.
  """
  def create(%{account: account, token: token}) do
    %{email: account.email, name: account.full_name, token: token}
  end
end
