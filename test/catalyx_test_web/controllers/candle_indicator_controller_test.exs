defmodule CatalyxTestWeb.CandleIndicatorControllerTest do
  use CatalyxTestWeb.ConnCase

  import CatalyxTest.FinancesFixtures

  alias CatalyxTest.Finances.CandleIndicator

  @create_attrs %{
    period: ~D[2023-08-07],
    opening_price: 120.5,
    closing_price: 120.5,
    highest_price: 120.5,
    lowest_price: 120.5,
    trend: 1,
    market_symbol: "some market_symbol"
  }
  @update_attrs %{
    period: ~D[2023-08-08],
    opening_price: 456.7,
    closing_price: 456.7,
    highest_price: 456.7,
    lowest_price: 456.7,
    trend: -1,
    market_symbol: "some updated market_symbol"
  }
  @invalid_attrs %{period: nil, opening_price: nil, closing_price: nil, highest_price: nil, lowest_price: nil, trend: nil, market_symbol: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_candle_indicator]

    test "lists last candle_indicators by time frame", %{conn: conn, candle_indicator: candle_indicator} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{size: "30", start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end

    test "lists last candle_indicators by time frame and market", %{conn: conn, candle_indicator: candle_indicator} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{size: "30", market: candle_indicator.market_symbol, start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame and market", %{conn: conn, candle_indicator: candle_indicator} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{market: candle_indicator.market_symbol, start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end

    test "lists all candle_indicators by time frame and not existing market", %{conn: conn, candle_indicator: candle_indicator} do
      conn = get(conn, ~p"/api/v1/candle_indicators", %{market: "not found", start: "2023-08-05", end: "2023-08-10"})
      assert [] = json_response(conn, 200)["data"]
    end
  end

  defp create_candle_indicator(_) do
    candle_indicator = candle_indicator_fixture()
    %{candle_indicator: candle_indicator}
  end
end
