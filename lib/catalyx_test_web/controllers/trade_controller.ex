defmodule CatalyxTestWeb.TradeController do
  use CatalyxTestWeb, :controller

  alias CatalyxTest.Finances
  alias CatalyxTest.Finances.Trade

  action_fallback CatalyxTestWeb.FallbackController

  def index(conn, %{"size" => size} = params) do
    symbol = Map.get(params, "symbol")

    trades =
      if is_nil(symbol) do
        Finances.list_trades([], size)
      else
        symbol = Map.get(params, "symbol")
        Finances.list_trades([market_symbol: symbol], size)
      end

    render(conn, :index, trades: trades)
  end

  def index(conn, %{"start" => start_date, "end" => end_date}) do
    with {_, {:ok, start_date}} <- {"start_date", Date.from_iso8601(start_date)},
         {_, {:ok, end_date}} <- {"end_date", Date.from_iso8601(end_date)} do
      trades = Finances.list_trades_time_frame(start_date, end_date)
      render(conn, :index, trades: trades)
    end
  end

  def index(conn, _params), do: index(conn, %{"size" => 50})

  def insert_multi(conn, params) do
    schema = %{
      data: [
        %{
          market_symbol: :string,
          amount: :number,
          price: :number,
          transaction_type: :string,
          executed_at: :string,
          external_id: :string
        }
      ]
    }

    with {:ok, _} <- MapSchemaValidator.validate(schema, params) do
      %{"data" => data} = params

      trades =
        Enum.map(data, fn trade_params ->
          date_time =
            trade_params
            |> Map.get("executed_at")
            |> NaiveDateTime.from_iso8601!()

          {:ok, %Trade{} = trade} =
            trade_params
            |> Map.put("executed_at_date", NaiveDateTime.to_date(date_time))
            |> Map.put("executed_at_time", NaiveDateTime.to_time(date_time))
            |> Finances.create_trade()

          trade
        end)

      conn
      |> put_status(:created)
      |> render(:index, trades: trades)
    end
  end
end
