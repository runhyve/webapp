defmodule Webapp.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:name, :string)
      add(:namespace, :string)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:teams, ["lower(name)"], name: :teams_name_index))
    create(unique_index(:teams, ["lower(namespace)"], name: :teams_namespace_index))
  end
end
