defmodule Webapp.Repo.Migrations.AddIsInactiveToHypervisor do
  use Ecto.Migration

  def change do
    alter table(:hypervisors) do
      add(:is_inactive, :boolean, default: false)
    end
  end
end
