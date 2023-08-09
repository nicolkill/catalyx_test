defmodule CatalyxTest.Finances.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "trades" do
    field :market_symbol, :string
    field :amount, :float
    field :price, :float
    field :transaction_type, Ecto.Enum, values: [:buy, :sell]
    field :executed_at_date, :date
    field :executed_at_time, :time
    field :external_id, :string
    field :processed, :boolean, default: false

    timestamps()
  end

  @required_fields [:market_symbol, :amount, :price, :transaction_type, :executed_at_date, :executed_at_time, :external_id]
  @fields @required_fields ++ [:processed]

  @doc false
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
