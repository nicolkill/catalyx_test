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
        executed_at: ~U[2023-08-07 17:38:00Z],
        external_id: "some external_id"
      })
      |> CatalyxTest.Finances.create_trade()

    trade
  end
end
