defmodule Webapp.Repo.Migrations.AddJobIdToMachines do
  use Ecto.Migration

  def change do
    alter table(:machines) do
      add(:job_id, :integer)
    end
  end
end
