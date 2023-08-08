defmodule CatalyxTest.AWS.S3Client do

  defp is_prod, do: Mix.env() == :prod
  defp s3_bucket, do: Application.get_env(:ex_aws, :s3)[:bucket]
  defp config, do: ExAws.Config.new(:s3, [])

  def presigned_url_upload(object_key, opts \\ []) do
    get_presigned_url(:put, object_key, opts)
  end

  defp get_presigned_url(http_method, object_key, opts) do
    # this its for a configuration issue with localhost
    opts =
      if is_prod() do
        opts
      else
        opts
        |> Keyword.put(:virtual_host, is_prod())
        |> Keyword.put(:bucket_as_host, true)
      end

    ExAws.S3.presigned_url(
      config(),
      http_method,
      s3_bucket(),
      object_key,
      opts
    )
  end

  def does_object_exist(object_key) do
    with {:ok, url} <- get_presigned_url(:head, object_key, virtual_host: is_prod()),
         {:ok, %HTTPoison.Response{status_code: 200}} <- HTTPoison.head(url) do
      :ok
    else
      _ ->
        :not_found
    end
  end

  def download_object(object_key, file_path),
      do:
        s3_bucket()
        |> ExAws.S3.download_file(object_key, file_path)
        |> ExAws.request()
end