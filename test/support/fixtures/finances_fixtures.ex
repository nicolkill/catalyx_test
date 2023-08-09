defmodule CatalyxTest.FinancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CatalyxTest.Finances` context.
  """

  @doc """
  Generate a trade.
  """
  def trade_fixture(attrs \\ %{}) do
    {:ok, trade} =
      attrs
      |> Enum.into(%{
        market_symbol: "some market_symbol",
        amount: 120.5,
        price: 120.5,
        transaction_type: :buy,
        executed_at_date: ~D[2023-08-07],
        executed_at_time: ~T[17:38:00Z],
        external_id: "some external_id"
      })
      |> CatalyxTest.Finances.create_trade()

    trade
  end

  @doc """
  Generate a candle_indicator.
  """
  def candle_indicator_fixture(attrs \\ %{}) do
    {:ok, candle_indicator} =
      attrs
      |> Enum.into(%{
        period: ~D[2023-08-07],
        opening_at: ~T[07:38:00Z],
        opening_price: 120.5,
        closing_at: ~T[17:38:00Z],
        closing_price: 120.5,
        highest_price: 120.5,
        lowest_price: 120.5,
        trend: 1,
        market_symbol: "some market_symbol"
      })
      |> CatalyxTest.Finances.create_candle_indicator()

    candle_indicator
  end
end
