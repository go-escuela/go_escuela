defmodule GoEscuelaLms.Core.GCP.Manager do
  @moduledoc """
  This module GCP uploader
  """
  require Logger

  @dialyzer {:no_return, {:upload, 2}}

  # sobelow_skip ["Traversal"]
  def upload(%{} = object, resource) do
    conn = connection()
    file_name = resource.filename
    path = resource.path
    content_type = resource.content_type

    meta = %GoogleApi.Storage.V1.Model.Object{
      name: "resources/#{object.uuid}",
      contentType: content_type
    }

    file_binary = File.open!(path)
    bytes = IO.binread(file_binary, :eof)

    object_result = insert_objects(conn, meta, bytes)

    result =
      case object_result do
        {:ok, %GoogleApi.Storage.V1.Model.Object{} = result} ->
          Logger.info("File uploaded to GCP Storage - #{file_name}")
          File.close(file_binary)
          {:ok, result.etag}

        {:error, message} ->
          Logger.info("File uploaded fail #{inspect(message)}")
          File.close(file_binary)
          {:error, message}
      end

    result
  end

  def insert_objects(conn, meta, bytes) do
    GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
      conn,
      "#{bucket()}",
      "multipart",
      meta,
      bytes
    )
  end

  def connection() do
    {:ok, token} = Goth.fetch(Core.Goth)
    GoogleApi.Storage.V1.Connection.new(token.token)
  end

  defp bucket() do
    Application.get_env(:core, :bucket)
  end
end
