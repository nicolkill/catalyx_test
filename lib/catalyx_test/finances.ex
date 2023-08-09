defmodule CatalyxTest.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias CatalyxTest.Repo

  alias CatalyxTest.Finances.CandleIndicator
  alias CatalyxTest.Finances.Trade

  defp last_trades_query(query, size) do
    query
    |> order_by([t], desc: t.executed_at_date, desc: t.executed_at_time)
    |> limit(^size)
  end

  @doc """
  Returns the list of trades.

  ## Examples

      iex> list_trades()
      [%Trade{}, ...]

  """
  @spec list_trades(integer()) :: [%Trade{}]
  def list_trades(size \\ 50) do
    Trade
    |> last_trades_query(size)
    |> Repo.all()
  end

  @spec list_trades_by_market_symbol(String.t(), integer()) :: [%Trade{}]
  def list_trades_by_market_symbol(market_symbol, size \\ 50) do
    Trade
    |> where(market_symbol: ^market_symbol)
    |> last_trades_query(size)
    |> Repo.all()
  end

  def trades_count_with_period() do
    Trade
    |> select([t], {t.executed_at_date, count(t.id)})
    |> group_by([t], t.executed_at_date)
    |> Repo.all()
  end

  def get_trades_by_period_stream(period) do
    Trade
    |> where(executed_at_date: ^period)
    |> Repo.stream()
  end

  @doc """
  Gets a single trade.

  Raises `Ecto.NoResultsError` if the Trade does not exist.

  ## Examples

      iex> get_trade!(123)
      %Trade{}

      iex> get_trade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trade!(id), do: Repo.get!(Trade, id)

  @doc """
  Creates a trade.

  ## Examples

      iex> create_trade(%{field: value})
      {:ok, %Trade{}}

      iex> create_trade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trade(attrs \\ %{}) do
    %Trade{}
    |> Trade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trade.

  ## Examples

      iex> update_trade(trade, %{field: new_value})
      {:ok, %Trade{}}

      iex> update_trade(trade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trade(%Trade{} = trade, attrs) do
    trade
    |> Trade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trade.

  ## Examples

      iex> delete_trade(trade)
      {:ok, %Trade{}}

      iex> delete_trade(trade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trade(%Trade{} = trade) do
    Repo.delete(trade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trade changes.

  ## Examples

      iex> change_trade(trade)
      %Ecto.Changeset{data: %Trade{}}

  """
  def change_trade(%Trade{} = trade, attrs \\ %{}) do
    Trade.changeset(trade, attrs)
  end

  def new_change_trade(attrs \\ %{}) do
    Trade.changeset(%Trade{}, attrs)
  end

  @doc """
  Returns the list of candle_indicators.

  ## Examples

      iex> list_candle_indicators()
      [%CandleIndicator{}, ...]

  """
  def list_candle_indicators(count \\ 20) do
    Repo.all(CandleIndicator)
  end

  def get_candle_indicator_by_period!(period, symbol) do
    indicator =
      CandleIndicator
      |> where(period: ^period)
      |> where(market_symbol: ^symbol)
      |> Repo.one()
    case indicator do
      nil ->
        %CandleIndicator{
          period: period,
          opening_at: ~T[23:59:59Z],
          opening_price: 0.0,
          closing_at: ~T[00:00:00Z],
          closing_price: 0.0,
          highest_price: 0.0,
          lowest_price: 100000.0,
          trend: 0,
          market_symbol: symbol
        }
      period_record ->
        period_record
    end
  end

  @doc """
  Gets a single candle_indicator.

  Raises `Ecto.NoResultsError` if the Candle indicator does not exist.

  ## Examples

      iex> get_candle_indicator!(123)
      %CandleIndicator{}

      iex> get_candle_indicator!(456)
      ** (Ecto.NoResultsError)

  """
  def get_candle_indicator!(id), do: Repo.get!(CandleIndicator, id)

  @doc """
  Creates a candle_indicator.

  ## Examples

      iex> create_candle_indicator(%{field: value})
      {:ok, %CandleIndicator{}}

      iex> create_candle_indicator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_candle_indicator(attrs \\ %{}) do
    %CandleIndicator{}
    |> CandleIndicator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a candle_indicator.

  ## Examples

      iex> update_candle_indicator(candle_indicator, %{field: new_value})
      {:ok, %CandleIndicator{}}

      iex> update_candle_indicator(candle_indicator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_candle_indicator(%CandleIndicator{} = candle_indicator, attrs) do
    candle_indicator
    |> CandleIndicator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a candle_indicator.

  ## Examples

      iex> delete_candle_indicator(candle_indicator)
      {:ok, %CandleIndicator{}}

      iex> delete_candle_indicator(candle_indicator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_candle_indicator(%CandleIndicator{} = candle_indicator) do
    Repo.delete(candle_indicator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking candle_indicator changes.

  ## Examples

      iex> change_candle_indicator(candle_indicator)
      %Ecto.Changeset{data: %CandleIndicator{}}

  """
  def change_candle_indicator(%CandleIndicator{} = candle_indicator, attrs \\ %{}) do
    CandleIndicator.changeset(candle_indicator, attrs)
  end
end
