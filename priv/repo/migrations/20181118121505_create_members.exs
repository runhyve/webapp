defmodule Webapp.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:team_id, references(:teams, on_delete: :delete_all), null: false)
      add(:role, :user_role)
      timestamps()
    end

    create(index(:members, [:user_id]))
    create(index(:members, [:team_id]))
  end
end
