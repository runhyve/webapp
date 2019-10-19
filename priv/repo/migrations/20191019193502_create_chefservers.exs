defmodule Webapp.Repo.Migrations.CreateChefservers do
  use Ecto.Migration

  def change do
    create table(:chefservers) do
      add :url, :string
      add :cacert, :string
      add :enabled, :boolean, default: false, null: false
      add :private_key, :string
      add :username, :string
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:chefservers, [:team_id])
  end
end
