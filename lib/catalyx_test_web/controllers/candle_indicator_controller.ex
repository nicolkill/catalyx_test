defmodule CatalyxTestWeb.CandleIndicatorController do
  use CatalyxTestWeb, :controller

  alias CatalyxTest.Finances
  alias CatalyxTest.Finances.CandleIndicator

  action_fallback CatalyxTestWeb.FallbackController

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
