defmodule Webapp.Repo.Migrations.CreateHypervisorTypes do
  use Ecto.Migration

  def change do
    create table(:hypervisor_types) do
      add :name, :string

      timestamps()
    end

  end
end