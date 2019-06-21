defmodule Webapp.Repo.Migrations.CreateDistributions do
  use Ecto.Migration

  def change do
    create table(:distributions) do
      add(:name, :string)
      add(:version, :string)
      add(:image, :string)
      add(:loader, :string)

      timestamps()
    end

    alter table(:machines) do
      add(:distribution_id, references(:distributions, on_delete: :nothing), null: true)
      remove(:template)
    end

    create(unique_index(:distributions, [:name, :version]))
  end
end
