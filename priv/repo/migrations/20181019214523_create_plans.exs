defmodule Webapp.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :name, :string
      add :storage, :integer, default: 10
      add :ram, :integer, default: 512
      add :cpu, :integer, default: 1

      timestamps()
    end

  end
end
