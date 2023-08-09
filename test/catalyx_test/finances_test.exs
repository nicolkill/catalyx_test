defmodule CatalyxTest.FinancesTest do
  use CatalyxTest.DataCase

  alias CatalyxTest.Finances

  describe "trades" do
    alias CatalyxTest.Finances.Trade

    import CatalyxTest.FinancesFixtures

    @invalid_attrs %{
      market_symbol: nil,
      amount: nil,
      price: nil,
      transaction_type: nil,
      executed_at: nil,
      external_id: nil
    }

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Finances.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Finances.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      valid_attrs = %{
        market_symbol: "some market_symbol",
        amount: 120.5,
        price: 120.5,
        transaction_type: :buy,
        executed_at_date: ~D[2023-08-07],
        executed_at_time: ~T[17:38:00Z],
        external_id: "some external_id"
      }

      assert {:ok, %Trade{} = trade} = Finances.create_trade(valid_attrs)
      assert trade.market_symbol == "some market_symbol"
      assert trade.amount == 120.5
      assert trade.price == 120.5
      assert trade.transaction_type == :buy
      assert trade.executed_at_date == ~D[2023-08-07]
      assert trade.executed_at_time == ~T[17:38:00Z]
      assert trade.external_id == "some external_id"
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finances.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()

      update_attrs = %{
        market_symbol: "some updated market_symbol",
        amount: 456.7,
        price: 456.7,
        transaction_type: :sell,
        executed_at_date: ~D[2023-08-08],
        executed_at_time: ~T[17:38:00Z],
        external_id: "some updated external_id"
      }

      assert {:ok, %Trade{} = trade} = Finances.update_trade(trade, update_attrs)
      assert trade.market_symbol == "some updated market_symbol"
      assert trade.amount == 456.7
      assert trade.price == 456.7
      assert trade.transaction_type == :sell
      assert trade.executed_at_date == ~D[2023-08-08]
      assert trade.executed_at_time == ~T[17:38:00Z]
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

  describe "candle_indicators" do
    alias CatalyxTest.Finances.CandleIndicator

    import CatalyxTest.FinancesFixtures

    @invalid_attrs %{
      period: nil,
      opening_at: nil,
      opening_price: nil,
      closing_price: nil,
      highest_price: nil,
      lowest_price: nil,
      trend: nil,
      market_symbol: nil
    }

    test "list_candle_indicators/0 returns all candle_indicators" do
      candle_indicator = candle_indicator_fixture()
      assert Finances.list_candle_indicators() == [candle_indicator]
    end

    test "get_candle_indicator!/1 returns the candle_indicator with given id" do
      candle_indicator = candle_indicator_fixture()
      assert Finances.get_candle_indicator!(candle_indicator.id) == candle_indicator
    end

    test "create_candle_indicator/1 with valid data creates a candle_indicator" do
      valid_attrs = %{
        period: ~D[2023-08-07],
        opening_at: ~T[07:38:00Z],
        opening_price: 120.5,
        closing_at: ~T[19:38:00Z],
        closing_price: 120.5,
        highest_price: 120.5,
        lowest_price: 120.5,
        trend: 1,
        market_symbol: "some market_symbol"
      }

      assert {:ok, %CandleIndicator{} = candle_indicator} =
               Finances.create_candle_indicator(valid_attrs)

      assert candle_indicator.period == ~D[2023-08-07]
      assert candle_indicator.opening_at == ~T[07:38:00Z]
      assert candle_indicator.opening_price == 120.5
      assert candle_indicator.closing_at == ~T[19:38:00Z]
      assert candle_indicator.closing_price == 120.5
      assert candle_indicator.highest_price == 120.5
      assert candle_indicator.lowest_price == 120.5
      assert candle_indicator.trend == 1
      assert candle_indicator.market_symbol == "some market_symbol"
    end

    test "create_candle_indicator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finances.create_candle_indicator(@invalid_attrs)
    end

    test "update_candle_indicator/2 with valid data updates the candle_indicator" do
      candle_indicator = candle_indicator_fixture()

      update_attrs = %{
        period: ~D[2023-08-08],
        opening_at: ~T[08:38:00Z],
        opening_price: 456.7,
        closing_at: ~T[18:38:00Z],
        closing_price: 456.7,
        highest_price: 456.7,
        lowest_price: 456.7,
        trend: -1,
        market_symbol: "some updated market_symbol"
      }

      assert {:ok, %CandleIndicator{} = candle_indicator} =
               Finances.update_candle_indicator(candle_indicator, update_attrs)

      assert candle_indicator.period == ~D[2023-08-08]
      assert candle_indicator.opening_at == ~T[08:38:00Z]
      assert candle_indicator.opening_price == 456.7
      assert candle_indicator.closing_at == ~T[18:38:00Z]
      assert candle_indicator.closing_price == 456.7
      assert candle_indicator.highest_price == 456.7
      assert candle_indicator.lowest_price == 456.7
      assert candle_indicator.trend == -1
      assert candle_indicator.market_symbol == "some updated market_symbol"
    end

    test "update_candle_indicator/2 with invalid data returns error changeset" do
      candle_indicator = candle_indicator_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Finances.update_candle_indicator(candle_indicator, @invalid_attrs)

      assert candle_indicator == Finances.get_candle_indicator!(candle_indicator.id)
    end

    test "delete_candle_indicator/1 deletes the candle_indicator" do
      candle_indicator = candle_indicator_fixture()
      assert {:ok, %CandleIndicator{}} = Finances.delete_candle_indicator(candle_indicator)

      assert_raise Ecto.NoResultsError, fn ->
        Finances.get_candle_indicator!(candle_indicator.id)
      end
    end

    test "change_candle_indicator/1 returns a candle_indicator changeset" do
      candle_indicator = candle_indicator_fixture()
      assert %Ecto.Changeset{} = Finances.change_candle_indicator(candle_indicator)
    end
  end
end
