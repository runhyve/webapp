defmodule Webapp.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :ts_job_id, :integer
      add :last_status, :string, default: "queued"
      add :e_level, :integer, default: nil, null: true
      add :hypervisor_id, references(:hypervisors, on_delete: :nothing)

      add(:started_at, :utc_datetime)
      add(:finished_at, :utc_datetime)
      timestamps(type: :utc_datetime)
    end

    create index(:jobs, [:hypervisor_id])
  end
end
