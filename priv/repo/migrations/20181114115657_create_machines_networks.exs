defmodule Webapp.Repo.Migrations.AddNetworkToMachines do
  use Ecto.Migration

  def change do
    create table(:machines_networks, primary_key: false) do
      add(:machine_id, references(:machines, on_delete: :delete_all), null: false)
      add(:network_id, references(:networks, on_delete: :delete_all), null: false)
    end

    create(index(:machines_networks, [:machine_id]))
    create(index(:machines_networks, [:network_id]))
  end
end
