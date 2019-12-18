defmodule Webapp.Repo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add(:uuid, :uuid)
      add(:name, :string)
      add(:network, :cidr)
      add(:hypervisor_id, references(:hypervisors, on_delete: :delete_all), null: false)

      timestamps(type: :utc_datetime)
    end

    create(index(:networks, [:hypervisor_id]))
    create(unique_index(:networks, [:name, :hypervisor_id]))
    create(unique_index(:networks, [:uuid]))
  end
end
