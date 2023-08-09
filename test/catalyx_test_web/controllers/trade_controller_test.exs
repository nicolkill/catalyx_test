defmodule CatalyxTestWeb.TradeControllerTest do
  use CatalyxTestWeb.ConnCase

  import CatalyxTest.FinancesFixtures

  alias CatalyxTest.Finances.Trade

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
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end

    test "get last n trades with symbol", %{conn: conn, trade: trade} do
      conn = get(conn, ~p"/api/v1/trades", %{size: "30", symbol: trade.market_symbol})
      assert [%{"id" => id} | _] = json_response(conn, 200)["data"]
    end
  end

  describe "trade actions" do

    test "insert single trade in multiple input", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/trades", data: [@create_attrs])
      assert [%{"id" => id} | _] = json_response(conn, 201)["data"]
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
