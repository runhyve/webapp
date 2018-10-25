defmodule Webapp.Repo.Migrations.CreateHypervisor do
  use Ecto.Migration

  def change do
    create table(:hypervisors) do
      add(:name, :string)
      add(:ip_address, :string)
      add(:hypervisor_type_id, references(:hypervisor_types, on_delete: :nothing))
      add(:webhook_endpoint, :string)

      timestamps()
    end

    create(index(:hypervisors, [:hypervisor_type_id]))
  end
end
