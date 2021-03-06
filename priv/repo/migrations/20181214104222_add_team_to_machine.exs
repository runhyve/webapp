defmodule Webapp.Repo.Migrations.AddTeamToMachine do
  use Ecto.Migration

  def change do
    alter table(:machines) do
      add(:team_id, references(:teams, on_delete: :delete_all), null: false)
    end

    create(unique_index(:machines, [:name, :team_id]))
  end
end
