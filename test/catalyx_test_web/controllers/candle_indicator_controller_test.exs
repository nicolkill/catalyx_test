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
    test "lists all candle_indicators", %{conn: conn} do
      conn = get(conn, ~p"/api/candle_indicators")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create candle_indicator" do
    test "renders candle_indicator when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/candle_indicators", candle_indicator: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/candle_indicators/#{id}")

      assert %{
               "id" => ^id,
               "closing_price" => 120.5,
               "highest_price" => 120.5,
               "lowest_price" => 120.5,
               "market_symbol" => "some market_symbol",
               "opening_price" => 120.5,
               "period" => "2023-08-07",
               "trend" => "bullish"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/candle_indicators", candle_indicator: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update candle_indicator" do
    setup [:create_candle_indicator]

    test "renders candle_indicator when data is valid", %{conn: conn, candle_indicator: %CandleIndicator{id: id} = candle_indicator} do
      conn = put(conn, ~p"/api/candle_indicators/#{candle_indicator}", candle_indicator: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/candle_indicators/#{id}")

      assert %{
               "id" => ^id,
               "closing_price" => 456.7,
               "highest_price" => 456.7,
               "lowest_price" => 456.7,
               "market_symbol" => "some updated market_symbol",
               "opening_price" => 456.7,
               "period" => "2023-08-08",
               "trend" => "bearish"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, candle_indicator: candle_indicator} do
      conn = put(conn, ~p"/api/candle_indicators/#{candle_indicator}", candle_indicator: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete candle_indicator" do
    setup [:create_candle_indicator]

    test "deletes chosen candle_indicator", %{conn: conn, candle_indicator: candle_indicator} do
      conn = delete(conn, ~p"/api/candle_indicators/#{candle_indicator}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/candle_indicators/#{candle_indicator}")
      end
    end
  end

  defp create_candle_indicator(_) do
    candle_indicator = candle_indicator_fixture()
    %{candle_indicator: candle_indicator}
  end
end
