defmodule CatalyxTest.TradeProcessor do
  @moduledoc """
  This modules works as a singleton processer, the point it's iterate the whole trades pages, create candle stats by
  periods and delete the records

  The point it's being optimal but talking about data it's better save this trades
  """
  use GenServer

  alias CatalyxTest.Finances
  alias CatalyxTest.Finances.Trade
  alias CatalyxTest.Finances.CandleIndicator

  @impl true
  def init(_) do
    process_trades()

    {:ok, false}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: TradeProcessor)
  end

  @impl true
  def handle_cast(:start, _) do
    {:noreply, true}
  end
  def handle_cast(:finish, _) do
    {:noreply, false}
  end

  def start_processing() do
    GenServer.cast(TradeProcessor, :start)
  end

  @impl true
  def handle_info(:trade_process, true), do: {:noreply, true}
  def handle_info(:trade_process, false) do
    Task.async(__MODULE__, :start_trades_processing, [])

    process_trades()

    {:noreply, false}
  end
  def handle_info(_, processing), do: {:noreply, processing}

  defp process_trades() do
    # check again in 5 seconds
    Process.send_after(self(), :trade_process, 5  * 1000)
  end

  def start_trades_processing() do
    Finances.trades_count_with_period()
    |> Enum.map(fn {period, _} ->
      Task.async(__MODULE__, :process_period, [period])
    end)

    start_processing()
  end

  @spec process_period(Date.t()) :: any()
  def process_period(period) do
    stream =
      period
      |> Finances.get_trades_by_period_stream()
      |> Stream.chunk_every(30)
      |> Stream.map(&process_chunk(period, &1))
    CatalyxTest.Repo.transaction(fn ->
      Stream.run(stream)
    end)
  end

  defp process_chunk(period, chunk) do
    chunk
    |> Enum.group_by(&(&1.market_symbol))
    |> Enum.map(&process_group(period, &1))
  end

  defp process_group(period, {market_symbol, data}) do
    %{
      trend: trend,
      opening_at: opening_at,
      opening_price: opening,
      closing_at: closing_at,
      closing_price: closing,
      highest_price: highest,
      lowest_price: lowest,
      sma_values: sma_values,
      sma_count: sma_count
    } = period_record = Finances.get_candle_indicator_by_period!(period, market_symbol)

    {transaction, new_sma_values, new_sma_count, trend, opening_at, opening, closing_at, closing, highest, lowest} =
      Enum.reduce(data, {Ecto.Multi.new(), [], 0, trend, opening_at, opening, closing_at, closing, highest, lowest}, fn
        trade, {transaction, sma_values, sma_count, trend, opening_at, opening, closing_at, closing, highest, lowest} ->
          %Trade{
            external_id: external_id,
            amount: amount,
            price: price,
            transaction_type: type,
            executed_at_time: executed_at_time
          } = trade

          trade = Finances.change_trade(trade, %{processed: true})

          int_amount = ceil(amount)
          unit_price = ((int_amount * price) / amount) / int_amount

          trend = trend + (if type == :sell, do: +1, else: -1)
          {opening_at, opening} =
            if Time.diff(opening_at, executed_at_time) > 0 do
              {executed_at_time, unit_price}
            else
              {opening_at, opening}
            end
          {closing_at, closing} =
            if Time.diff(executed_at_time, closing_at) > 0 do
              {executed_at_time, unit_price}
            else
              {closing_at, closing}
            end

          highest = if unit_price > highest, do: unit_price, else: highest
          lowest = if unit_price < lowest, do: unit_price, else: lowest

          {
            Ecto.Multi.update(transaction, "#{market_symbol}_#{external_id}", trade),
            [unit_price | sma_values],
            sma_count + 1,
            trend,
            opening_at,
            opening,
            closing_at,
            closing,
            highest,
            lowest
          }
      end)

    period_record = Finances.change_candle_indicator(period_record, %{
      trend: trend,
      opening_at: opening_at,
      opening_price: opening,
      closing_at: closing_at,
      closing_price: closing,
      highest_price: highest,
      lowest_price: lowest,
      sma_values: sma_values ++ new_sma_values,
      sma_count: sma_count + new_sma_count
    })

    transaction
    |> Ecto.Multi.insert_or_update("upsert_period_record_#{inspect(period)}_#{market_symbol}", period_record)
    |> CatalyxTest.Repo.transaction()
  end

end
