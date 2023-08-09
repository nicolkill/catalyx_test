defmodule CatalyxTestWeb.CandleIndicatorController do
  use CatalyxTestWeb, :controller

  alias CatalyxTest.Finances
  alias CatalyxTest.Finances.CandleIndicator

  action_fallback CatalyxTestWeb.FallbackController

  def index(conn, %{"size" => size, "start" => start_date, "end" => end_date} = params) do
    with {_, {:ok, start_date}} <- {"start_date", Date.from_iso8601(start_date)},
         {_, {:ok, end_date}} <- {"end_date", Date.from_iso8601(end_date)} do
      market = Map.get(params, "market")
      query = if is_nil(market), do: [], else: [market_symbol: market]

      candle_indicators = Finances.last_candle_indicators_time_frame(start_date, end_date, query, size)
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












  def index(conn, _params) do
    candle_indicators = Finances.list_candle_indicators()
    render(conn, :index, candle_indicators: candle_indicators)
  end

  def create(conn, %{"candle_indicator" => candle_indicator_params}) do
    with {:ok, %CandleIndicator{} = candle_indicator} <- Finances.create_candle_indicator(candle_indicator_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/candle_indicators/#{candle_indicator}")
      |> render(:show, candle_indicator: candle_indicator)
    end
  end

  def show(conn, %{"id" => id}) do
    candle_indicator = Finances.get_candle_indicator!(id)
    render(conn, :show, candle_indicator: candle_indicator)
  end

  def update(conn, %{"id" => id, "candle_indicator" => candle_indicator_params}) do
    candle_indicator = Finances.get_candle_indicator!(id)

    with {:ok, %CandleIndicator{} = candle_indicator} <- Finances.update_candle_indicator(candle_indicator, candle_indicator_params) do
      render(conn, :show, candle_indicator: candle_indicator)
    end
  end

  def delete(conn, %{"id" => id}) do
    candle_indicator = Finances.get_candle_indicator!(id)

    with {:ok, %CandleIndicator{}} <- Finances.delete_candle_indicator(candle_indicator) do
      send_resp(conn, :no_content, "")
    end
  end
end
