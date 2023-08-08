defmodule CatalyxTestWeb.ProcessTest do
  use CatalyxTestWeb.ConnCase

  import Mock

  alias CatalyxTest.CsvProcessor
  alias CatalyxTest.Broadway.NewFileEventHandler

  test "get presigned url, push file and verify genserver queued files", %{conn: conn} do
    assert %{resp_body: body} = post(conn, "/api/v1/get_presigned_url")
    assert %{"url" => url} = Jason.decode!(body)

    with_mock HTTPoison, [put!: fn(_url, _params) -> %{status_code: 204} end] do
      %{status_code: code} = HTTPoison.put!(url, {:file, "/example/path"})

      message = %{
        "Records" => [
          %{
            "eventVersion" => "2.1",
            "eventSource" => "aws:s3",
            "awsRegion" => "us-west-2",
            "eventTime" => "1970-01-01T00:00:00.000Z",
            "eventName" => "ObjectCreated:Put",
            "userIdentity" => %{
              "principalId" => "AIDAJDPLRKLG7UEXAMPLE"
            },
            "requestParameters" => %{
              "sourceIPAddress" => "127.0.0.1"
            },
            "responseElements" => %{
              "x-amz-request-id" => "C3D13FE58DE4C810",
              "x-amz-id-2" => "FMyUVURIY8/IgAtTv8xRjskZQpcIZ9KG4V5Wp6S7S/JRWeUWerMUE5JgHvANOjpD"
            },
            "s3" => %{
              "s3SchemaVersion" => "1.0",
              "configurationId" => "testConfigRule",
              "bucket" => %{
                "name" => "files",
                "ownerIdentity" => %{
                  "principalId" => "A3NL1KOZZKExample"
                },
                "arn" => "arn:aws:s3:::files"
              },
              "object" => %{
                "key" => "test_file.csv",
                "size" => 1024,
                "eTag" => "d41d8cd98f00b204e9800998ecf8427e",
                "versionId" => "096fKKXTRTtl3on89fVO.nfljtsv6qko",
                "sequencer" => "0055AED6DCD90281E5"
              }
            }
          }
        ]
      }

      ref =
        Broadway.test_message(
          NewFileEventHandler,
          Jason.encode!(%{
            "Message" => Jason.encode!(message)
          })
        )

      assert_receive {:ack, ^ref, [%{data: ^message}], []}
      assert {["test_file.csv"], false} == CsvProcessor.lookup()
    end
  end

  test "process_file", %{conn: _conn}  do
    with_mocks([
      {CatalyxTest.AWS.S3Client,
        [],
        [does_object_exist: fn(_) -> :ok end]},
      {CatalyxTest.AWS.S3Client,
        [],
        [download_object: fn(_, _) -> {:ok, :done} end]}
    ]) do
      assert :ok = CsvProcessor.process_file("example.csv")
                   |> IO.inspect(label: "CsvProcessor.process_file")
    end
  end

end