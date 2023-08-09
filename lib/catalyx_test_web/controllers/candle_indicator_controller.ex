defmodule CatalyxTestWeb.CandleIndicatorController do
  use CatalyxTestWeb, :controller

  alias CatalyxTest.Finances

  action_fallback CatalyxTestWeb.FallbackController

  @six_months 30 * 6

  def index(conn, %{"size" => size, "start" => start_date, "end" => end_date} = params) do
    with {_, {:ok, start_date}} <- {"start_date", Date.from_iso8601(start_date)},
         {_, {:ok, end_date}} <- {"end_date", Date.from_iso8601(end_date)} do
      market = Map.get(params, "market")
      query = if is_nil(market), do: [], else: [market_symbol: market]

      candle_indicators =
        Finances.last_candle_indicators_time_frame(start_date, end_date, query, size)

      render(conn, :index, candle_indicators: candle_indicators)
    end
  end

  def index(conn, %{"start" => start_date, "end" => end_date} = params) do
    with {_, {:ok, start_date}} <- {"start_date", Date.from_iso8601(start_date)},
         {_, {:ok, end_date}} <- {"end_date", Date.from_iso8601(end_date)} do
      market = Map.get(params, "market")
      query = if is_nil(market), do: [], else: [market_symbol: market]

      candle_indicators = Finances.list_candle_indicators_time_frame(start_date, end_date, query)
      render(conn, :index, candle_indicators: candle_indicators)
    end
  end

  def sma_index(conn, %{"market" => market} = params) do
    start_date = Map.get(params, "start_date", "")
    end_date = Map.get(params, "end_date", "")

    {start_date, end_date} =
      with {_, {:ok, start_date}} <- {"start_date", Date.from_iso8601(start_date)},
           {_, {:ok, end_date}} <- {"end_date", Date.from_iso8601(end_date)} do
        {start_date, end_date}
      else
        _ ->
          today = Date.utc_today()
          {Date.add(today, -@six_months), today}
      end

    candle_indicators =
      Finances.list_candle_indicators_time_frame(start_date, end_date, market_symbol: market)

    render(conn, :sma_index, candle_indicators: candle_indicators)
  end

  def sma_show(conn, %{"market" => market, "date" => date}) do
    with {_, {:ok, date}} <- {"date", Date.from_iso8601(date)} do
      candle_indicator = Finances.get_candle_indicator_query(market_symbol: market, period: date)
      render(conn, :sma_show, candle_indicator: candle_indicator)
    end
  end
end
