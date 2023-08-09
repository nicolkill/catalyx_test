defmodule CatalyxTest.Repo.Migrations.ChangeTradesTime do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :executed_at_time, :time
      add :executed_at_date, :date
      remove :executed_at, :string
    end
  end
end
