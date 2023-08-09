defmodule CatalyxTest.Repo.Migrations.AddSmaFields do
  use Ecto.Migration

  def change do
    alter table(:candle_indicators) do
      add :sma_values, {:array, :float}
      add :sma_count, :integer
    end
  end
end
