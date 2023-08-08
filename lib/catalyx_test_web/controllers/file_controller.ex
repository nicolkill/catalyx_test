defmodule CatalyxTestWeb.FileController do
  use CatalyxTestWeb, :controller

  alias CatalyxTest.Generator
  alias CatalyxTest.AWS.S3Client

  # 30 mins
  @presigned_upload_url_max_age 60 * 30
  # 100 MB
  @presigned_upload_url_max_file_size 100 * 1_000_000

  # specs for the presigned urls:
  #   - must starts with `Content-Type` header
  #   - the link expires in 30 minutes
  #   - the max file size its 100mb
  @presigned_url_opts [
    ["starts-with", "$Content-Type", ""],
    {:expires_in, @presigned_upload_url_max_age},
    {:content_length_range, [1, @presigned_upload_url_max_file_size]}
  ]

  @doc """
  This function generates a presigned url to push a file to s3 and then the bucket will do their work in the queues
  """
  def get_presigned_url(conn, _) do
    file_name = "file_#{Generator.generate_unique_ref()}.csv"

    {:ok, url} =
      S3Client.presigned_url_upload(file_name, @presigned_url_opts)

    conn
    |> put_status(200)
    |> render("upload_url.json", url: url)
  end
end