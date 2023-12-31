defmodule CatalyxTestWeb.TradeControllerTest do
  use CatalyxTestWeb.ConnCase

  import CatalyxTest.FinancesFixtures

  @create_attrs %{
    market_symbol: "some market_symbol",
    amount: 1.25,
    price: 120.5,
    transaction_type: "buy",
    executed_at: "2023-08-07 17:38:00Z",
    external_id: "some external_id"
  }
  @invalid_attrs %{
    market_symbol: "some market_symbol",
    amount: 1.25,
    transaction_type: "buy",
    executed_at: "2023-08-07 17:38:00Z",
    external_id: "some external_id"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "trade queries" do
    setup [:create_trade]

    test "get last n trades", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/trades", %{size: "30"})
      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "get last n trades with symbol", %{conn: conn, trade: trade} do
      conn = get(conn, ~p"/api/v1/trades", %{size: "30", market: trade.market_symbol})
      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "get last n trades with time frame", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/trades", %{start: "2023-08-05", end: "2023-08-10"})
      assert [%{"id" => _id} | _] = json_response(conn, 200)["data"]
    end

    test "get last n trades with time frame out of date", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/trades", %{start: "2023-08-08", end: "2023-08-10"})
      assert [] = json_response(conn, 200)["data"]
    end

    test "get last n trades with time frame invalid date", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/trades", %{start: "2023-08-08", end: "not_valid"})
      assert ["end_date has invalid format"] == json_response(conn, 422)["errors"]
    end
  end

  describe "trade actions" do
    test "insert single trade in multiple input", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/trades", data: [@create_attrs])
      assert [%{"id" => _id} | _] = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/trades", data: [@invalid_attrs])
      assert ["error at: data -> price"] == json_response(conn, 422)["errors"]
    end
  end

  defp create_trade(_) do
    trade = trade_fixture()
    %{trade: trade}
  end
end
