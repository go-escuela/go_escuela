defmodule Web.InstitutionInfoControllerTest do
  use ExUnit.Case
  use Core.DataCase
  use Web.ConnCase

  import Web.Auth.Guardian
  import Core.Factory

  setup do
    institution = insert!(:institution_info)
    organizer = insert!(:user, role: :organizer)

    {:ok, institution: institution, organizer: organizer}
  end

  describe "show/2" do
    test "display institution info", %{organizer: organizer, institution: institution} do
      {:ok, token, _} = encode_and_sign(organizer, %{}, token_type: :access)

      conn =
        session_conn()
        |> put_session(:user_id, organizer.uuid)
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/onboarding/institution_info")

      response = json_response(conn, 200)["data"]

      assert response == %{"name" => institution.name}
    end
  end
end
