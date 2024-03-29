defmodule Web.PageControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  describe "show/2" do
    test "return ok", %{conn: conn} do
      conn = conn |> put_req_header("accept", "application/json") |> get(~p"/api")
      assert json_response(conn, 200)
    end
  end
end
