defmodule Webapp.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:name, :citext)
      add(:namespace, :citext)

      timestamps()
    end

    create(unique_index(:teams, [:name]))
    create(unique_index(:teams, [:namespace]))
  end
end
