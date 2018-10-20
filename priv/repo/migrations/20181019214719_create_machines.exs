defmodule Webapp.Repo.Migrations.CreateMachines do
  use Ecto.Migration

  def change do
    create table(:machines) do
      add :name, :string
      add :template, :string
      add :hypervisor_id, references(:hypervisors, on_delete: :nothing)
      add :plan_id, references(:plans, on_delete: :nothing)

      timestamps()
    end

    create index(:machines, [:hypervisor_id])
  end
end
