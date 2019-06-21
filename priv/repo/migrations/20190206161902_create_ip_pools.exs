defmodule Webapp.Repo.Migrations.CreateIpPools do
  use Ecto.Migration

  def change do
    create table(:ip_pools) do
      add(:name, :string)
      add(:ip_range, :string)
      add(:netmask, :inet)
      add(:gateway, :inet)
      add(:network_id, references(:networks, on_delete: :delete_all))

      timestamps()
    end

    create(index(:ip_pools, [:network_id]))
  end
end
