defmodule Webapp.Repo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add(:name, :string)
      add(:network, :cidr)
      add(:hypervisor_id, references(:hypervisors, on_delete: :nothing))

      timestamps()
    end

    create(index(:networks, [:hypervisor_id]))
    create(unique_index(:networks, [:name, :hypervisor_id]))
  end
end
