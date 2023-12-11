defmodule Web.Onboarding.InstitutionInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  plug :is_authorized when action in [:show, :create, :update]

  def show(conn, _params) do
    render(conn, :index, %{})
  end

  def create(conn, _params) do
    render(conn, :update, %{})
  end

  def update(conn, _params) do
    render(conn, :update, %{})
  end
end
