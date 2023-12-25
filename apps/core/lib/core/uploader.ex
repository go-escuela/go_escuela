defmodule GoEscuelaLms.Core.GCP.Manager do
  @moduledoc """
  This module GCP uploader
  """
  require Logger

  def upload(object, resource) do
    conn = connection()
    file_name = resource.filename
    path = resource.path

    meta = %GoogleApi.Storage.V1.Model.Object{
      name: "resources/#{object.uuid}",
      contentType: "text/csv"
    }

    file_binary = File.open!(path)
    bytes = IO.binread(file_binary, :all)
    bucket = Application.get_env(:core, :bucket)

    upload_result =
      GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
        conn,
        "#{bucket}",
        "multipart",
        meta,
        bytes
      )

    case upload_result do
      {:ok, %GoogleApi.Storage.V1.Model.Object{} = result} ->
        Logger.info("File uploaded to GCP Storage - #{file_name}")
        File.close(file_binary)
        {:ok, result.etag}

      {:error, message} ->
        Logger.info("File uploaded fail #{inspect(message)}")
        File.close(file_binary)
        {:error, message}
    end
  end

  def connection() do
    {:ok, token} = Goth.fetch(Core.Goth)
    GoogleApi.Storage.V1.Connection.new(token.token)
  end
end
