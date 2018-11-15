defmodule Webapp.Repo.Migrations.CreateHypervisor do
  use Ecto.Migration

  def change do
    create table(:hypervisors) do
      add(:name, :string)
      add(:ip_address, :inet)
      add(:hypervisor_type_id, references(:hypervisor_types, on_delete: :nothing))
      add(:webhook_endpoint, :string)
      add(:webhook_token, :string)

      timestamps()
    end

    create(index(:hypervisors, [:hypervisor_type_id]))
    create(unique_index(:hypervisors, [:name]))
  end
end
