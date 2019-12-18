defmodule Webapp.Repo.Migrations.CreateIpv4 do
  use Ecto.Migration

  def change do
    create table(:ipv4) do
      add(:ip, :inet)
      add(:reserved, :boolean)
      add(:ip_pool_id, references(:ip_pools, on_delete: :delete_all))
      add(:machine_id, references(:machines, on_delete: :nilify_all))

      timestamps(type: :utc_datetime)
    end

    create(index(:ipv4, [:ip_pool_id]))
    create(index(:ipv4, [:machine_id]))
  end
end
