defmodule CatalyxTest.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :market_symbol, :string
      add :amount, :float
      add :price, :float
      add :transaction_type, :string
      add :executed_at, :utc_datetime
      add :external_id, :string

      timestamps()
    end
  end
end
