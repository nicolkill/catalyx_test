defmodule CatalyxTestWeb.TradeJSON do
  alias CatalyxTest.Finances.Trade

  @doc """
  Renders a list of trades.
  """
  def index(%{trades: trades}) do
    %{data: for(trade <- trades, do: data(trade))}
  end

  @doc """
  Renders a single trade.
  """
  def show(%{trade: trade}) do
    %{data: data(trade)}
  end

  defp data(%Trade{} = trade) do
    %{
      id: trade.id,
      market_symbol: trade.market_symbol,
      amount: trade.amount,
      price: trade.price,
      transaction_type: trade.transaction_type,
      executed_at: "#{trade.executed_at_date}T#{trade.executed_at_time}",
      external_id: trade.external_id
    }
  end
end
