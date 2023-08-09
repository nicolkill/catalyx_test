defmodule CatalyxTestWeb.ProcessTest do
  use CatalyxTestWeb.ConnCase

  import Mock

  alias CatalyxTest.Finances
  alias CatalyxTest.CsvProcessor
  alias CatalyxTest.TradeProcessor
  alias CatalyxTest.Broadway.NewFileEventHandler

  test "get presigned url, push file and verify genserver queued files", %{conn: conn} do
    assert %{resp_body: body} = post(conn, "/api/v1/get_presigned_url")
    assert %{"url" => url} = Jason.decode!(body)

    with_mock HTTPoison, put!: fn _url, _params -> %{status_code: 204} end do
      %{status_code: _code} = HTTPoison.put!(url, {:file, "/example/path"})

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

  test "process_file", %{conn: _conn} do
    with_mocks([
      {CatalyxTest.AWS.S3Client, [], [does_object_exist: fn _ -> :ok end]},
      {CatalyxTest.AWS.S3Client, [], [download_object: fn _, _ -> {:ok, :done} end]}
    ]) do
      assert :ok = CsvProcessor.process_file("example.csv")
      assert {:ok, :ok} = TradeProcessor.process_period(~D[2023-07-30])

      assert [
               %CatalyxTest.Finances.CandleIndicator{
                 period: ~D[2023-07-30],
                 opening_at: ~T[00:00:05],
                 opening_price: 2.3274308180866534e-8,
                 closing_at: ~T[00:16:56],
                 closing_price: 3.2227031890371976e-7,
                 highest_price: 3.2227031890371976e-7,
                 lowest_price: 2.3274308180866534e-8,
                 trend: 0,
                 market_symbol: "BAT-BTC"
               },
               %CatalyxTest.Finances.CandleIndicator{
                 period: ~D[2023-07-30],
                 opening_at: ~T[00:19:30],
                 opening_price: 95_753_985.9902562,
                 closing_at: ~T[00:19:30],
                 closing_price: 95_753_985.9902562,
                 highest_price: 95_753_985.9902562,
                 lowest_price: 100_000.0,
                 trend: 1,
                 market_symbol: "BTC-CAD"
               },
               %CatalyxTest.Finances.CandleIndicator{
                 period: ~D[2023-07-30],
                 opening_at: ~T[04:30:12],
                 opening_price: 71_475_930.8892505,
                 closing_at: ~T[04:30:12],
                 closing_price: 71_475_930.8892505,
                 highest_price: 71_475_930.8892505,
                 lowest_price: 100_000.0,
                 trend: -1,
                 market_symbol: "BTC-USD"
               },
               %CatalyxTest.Finances.CandleIndicator{
                 period: ~D[2023-07-30],
                 opening_at: ~T[00:02:58],
                 opening_price: 4.5e-10,
                 closing_at: ~T[00:50:13],
                 closing_price: 2.7e-10,
                 highest_price: 4.5e-10,
                 lowest_price: 2.7e-10,
                 trend: 0,
                 market_symbol: "DGB-BTC"
               },
               %CatalyxTest.Finances.CandleIndicator{
                 period: ~D[2023-07-30],
                 opening_at: ~T[00:19:45],
                 opening_price: 2.3764583333333333e-4,
                 closing_at: ~T[00:19:56],
                 closing_price: 9.512810356688695e-5,
                 highest_price: 2.3764583333333333e-4,
                 lowest_price: 9.512810356688695e-5,
                 trend: -3,
                 market_symbol: "NMR-BTC"
               }
             ] = Finances.list_candle_indicators()
    end
  end
end
