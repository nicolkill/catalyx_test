defmodule CatalyxTest.Repo.Migrations.CreateCandleIndicators do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :processed, :boolean, default: false
    end
  end
end
