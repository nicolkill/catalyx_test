defmodule CatalyxTest.Finances.CandleIndicator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "candle_indicators" do
    field :period, :date
    field :opening_at, :time
    field :opening_price, :float
    field :closing_at, :time
    field :closing_price, :float
    field :highest_price, :float
    field :lowest_price, :float
    field :trend, :integer
    field :market_symbol, :string

    timestamps()
  end

  @fields [:opening_at, :opening_price, :closing_at, :closing_price, :highest_price, :lowest_price, :trend, :period, :market_symbol]
  @required_fields @fields

  @doc false
  def changeset(candle_indicator, attrs) do
    candle_indicator
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
