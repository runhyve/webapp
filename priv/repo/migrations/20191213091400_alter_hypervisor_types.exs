defmodule Webapp.Repo.Migrations.AlterHypervisorTypes do
  use Ecto.Migration

  def change do
    create(unique_index(:hypervisor_types, [:name]))
  end
end
