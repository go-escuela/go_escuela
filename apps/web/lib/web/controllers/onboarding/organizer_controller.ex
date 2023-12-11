defmodule Web.Onboarding.OrganizerController do
  use Web, :controller

  action_fallback Web.FallbackController

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
