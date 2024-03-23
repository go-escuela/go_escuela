defmodule Core.ManagerTest do
  use ExUnit.Case

  import Mock

  alias GoEscuelaLms.Core.GCP.Manager, as: GCPManager

  describe "upload/2" do
    test "upload" do
      with_mocks [
        {Goth, [:passthrough], fetch: fn _ -> {:ok, %{token: "token"}} end},
        {GCPManager, [:passthrough], connection: fn -> {:ok, "token"} end},
        {GoogleApi.Storage.V1.Api.Objects, [:passthrough],
         storage_objects_insert_iodata: fn _, _, _, _, _ ->
           {:ok, %GoogleApi.Storage.V1.Model.Object{etag: "uploaded"}}
         end}
      ] do
        attrs = %{
          filename: Faker.File.file_name(),
          path: "test/fixtures/example.txt",
          content_type: "text/plain"
        }

        {:ok, response} = GCPManager.upload(%{uuid: Faker.UUID.v4()}, attrs)

        assert response == "uploaded"
      end
    end
  end
end
