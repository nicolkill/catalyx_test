defmodule CatalyxTest.Repo.Migrations.CreateCandleIndicators do
  use Ecto.Migration

  def change do
    create table(:candle_indicators, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :opening_at, :time
      add :opening_price, :float
      add :closing_at, :time
      add :closing_price, :float
      add :highest_price, :float
      add :lowest_price, :float
      add :trend, :integer
      add :period, :date
      add :market_symbol, :string

      timestamps()
    end
  end
end
