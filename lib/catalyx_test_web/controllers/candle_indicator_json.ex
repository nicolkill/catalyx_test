defmodule CatalyxTestWeb.CandleIndicatorJSON do
  alias CatalyxTest.Finances.CandleIndicator

  @doc """
  Renders a list of candle_indicators.
  """
  def index(%{candle_indicators: candle_indicators}) do
    %{data: for(candle_indicator <- candle_indicators, do: data(candle_indicator))}
  end

  @doc """
  Renders a single candle_indicator.
  """
  def show(%{candle_indicator: candle_indicator}) do
    %{data: data(candle_indicator)}
  end

  defp data(%CandleIndicator{} = candle_indicator) do
    %{
      id: candle_indicator.id,
      opening_price: candle_indicator.opening_price,
      closing_price: candle_indicator.closing_price,
      highest_price: candle_indicator.highest_price,
      lowest_price: candle_indicator.lowest_price,
      trend: candle_indicator.trend,
      period: candle_indicator.period,
      market_symbol: candle_indicator.market_symbol
    }
  end
end
