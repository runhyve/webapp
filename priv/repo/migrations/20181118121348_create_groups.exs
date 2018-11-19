defmodule Webapp.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add(:name, :string)
      add(:namespace, :string)

      timestamps()
    end
  end
end
