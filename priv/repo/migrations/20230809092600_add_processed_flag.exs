defmodule CatalyxTest.Repo.Migrations.AddProcessedFlag do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :processed, :boolean, default: false
    end
  end
end
