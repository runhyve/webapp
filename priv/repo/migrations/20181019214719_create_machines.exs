defmodule Webapp.Repo.Migrations.CreateMachines do
  use Ecto.Migration

  def change do
    create table(:machines) do
      add(:uuid, :uuid)
      add(:name, :string)
      add(:template, :string)
      add(:hypervisor_id, references(:hypervisors, on_delete: :delete_all), null: false)
      add(:plan_id, references(:plans, on_delete: :nothing))
      add(:last_status, :string, default: "")
      add(:created, :boolean)
      add(:failed, :boolean)
      add(:job_id, :integer, null: true)

      add(:created_at, :utc_datetime)
      add(:failed_at, :utc_datetime)

      timestamps(type: :utc_datetime)
    end

    create(index(:machines, [:hypervisor_id]))
    create(unique_index(:machines, [:uuid]))
  end
end
