defmodule CatalyxTestWeb.CandleIndicatorControllerTest do
  use CatalyxTestWeb.ConnCase

  import CatalyxTest.FinancesFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_candle_indicator]

    test "lists last candle_indicators by time frame", %{conn: conn} do
      conn =
        get(conn, ~p"/api/v1/candle_indicators", %{
          size: "30",
          start: "2023-08-05",
          end: "2023-08-10"
        })

      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "lists last candle_indicators by time frame and market", %{
      conn: conn,
      candle_indicator: candle_indicator
    } do
      conn =
        get(conn, ~p"/api/v1/candle_indicators", %{
          size: "30",
          market: candle_indicator.market_symbol,
          start: "2023-08-05",
          end: "2023-08-10"
        })

      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame and market", %{
      conn: conn,
      candle_indicator: candle_indicator
    } do
      conn =
        get(conn, ~p"/api/v1/candle_indicators", %{
          market: candle_indicator.market_symbol,
          start: "2023-08-05",
          end: "2023-08-10"
        })

      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame and not existing market", %{conn: conn} do
      conn =
        get(conn, ~p"/api/v1/candle_indicators", %{
          market: "not found",
          start: "2023-08-05",
          end: "2023-08-10"
        })

      assert [] = json_response(conn, 200)["data"]
    end

    test "sma candle_indicators", %{conn: conn, candle_indicator: candle_indicator} do
      conn = get(conn, ~p"/api/v1/candle_indicators/#{candle_indicator.market_symbol}/sma")
      assert [%{"period" => "2023-08-07", "sma" => 25.0}] = json_response(conn, 200)["data"]
    end

    test "single sma candle_indicators", %{conn: conn, candle_indicator: candle_indicator} do
      conn =
        get(conn, ~p"/api/v1/candle_indicators/#{candle_indicator.market_symbol}/sma_show", %{
          date: "2023-08-07"
        })

      assert %{"period" => "2023-08-07", "sma" => 25.0} = json_response(conn, 200)["data"]
    end
  end

  defp create_candle_indicator(_) do
    candle_indicator = candle_indicator_fixture()
    %{candle_indicator: candle_indicator}
  end
end
