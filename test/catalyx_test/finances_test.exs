defmodule CatalyxTest.FinancesTest do
  use CatalyxTest.DataCase

  alias CatalyxTest.Finances

  describe "trades" do
    alias CatalyxTest.Finances.Trade

    import CatalyxTest.FinancesFixtures

    @invalid_attrs %{market_symbol: nil, amount: nil, price: nil, transaction_type: nil, executed_at: nil, external_id: nil}

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Finances.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Finances.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      valid_attrs = %{market_symbol: "some market_symbol", amount: 120.5, price: 120.5, transaction_type: :buy, executed_at: ~U[2023-08-07 17:38:00Z], external_id: "some external_id"}

      assert {:ok, %Trade{} = trade} = Finances.create_trade(valid_attrs)
      assert trade.market_symbol == "some market_symbol"
      assert trade.amount == 120.5
      assert trade.price == 120.5
      assert trade.transaction_type == :buy
      assert trade.executed_at == ~U[2023-08-07 17:38:00Z]
      assert trade.external_id == "some external_id"
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finances.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      update_attrs = %{market_symbol: "some updated market_symbol", amount: 456.7, price: 456.7, transaction_type: :sell, executed_at: ~U[2023-08-08 17:38:00Z], external_id: "some updated external_id"}

      assert {:ok, %Trade{} = trade} = Finances.update_trade(trade, update_attrs)
      assert trade.market_symbol == "some updated market_symbol"
      assert trade.amount == 456.7
      assert trade.price == 456.7
      assert trade.transaction_type == :sell
      assert trade.executed_at == ~U[2023-08-08 17:38:00Z]
      assert trade.external_id == "some updated external_id"
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_trade(trade, @invalid_attrs)
      assert trade == Finances.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Finances.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Finances.change_trade(trade)
    end
  end
end
