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

  def sma_index(%{candle_indicators: candle_indicators}) do
    %{data: for(candle_indicator <- candle_indicators, do: sma(candle_indicator))}
  end

  def sma_show(%{candle_indicator: candle_indicator}) do
    %{data: sma(candle_indicator)}
  end

  defp trend_enum(trend) when trend >= 0, do: :bullish
  defp trend_enum(trend), do: :bearish

  defp data(%CandleIndicator{} = candle_indicator) do
    %{
      id: candle_indicator.id,
      opening_price: candle_indicator.opening_price,
      closing_price: candle_indicator.closing_price,
      highest_price: candle_indicator.highest_price,
      lowest_price: candle_indicator.lowest_price,
      trend: trend_enum(candle_indicator.trend),
      period: candle_indicator.period,
      market_symbol: candle_indicator.market_symbol
    }
  end

  defp sma(%CandleIndicator{} = candle_indicator) do
    %{
      period: candle_indicator.period,
      sma: Enum.sum(candle_indicator.sma_values) / candle_indicator.sma_count
    }
  end
end
