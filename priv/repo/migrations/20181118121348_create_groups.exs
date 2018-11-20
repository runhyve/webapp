defmodule Webapp.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add(:name, :string)
      add(:namespace_id, references(:namespaces, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:groups, [:namespace_id]))
  end
end
