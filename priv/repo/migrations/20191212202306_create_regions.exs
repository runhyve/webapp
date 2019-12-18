defmodule Webapp.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:regions, [:name])

    alter table(:hypervisors) do
      add :region_id, references(:regions)
    end
  end
end
