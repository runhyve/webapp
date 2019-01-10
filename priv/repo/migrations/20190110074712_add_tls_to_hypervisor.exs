defmodule Webapp.Repo.Migrations.AddTlsToHypervisor do
  use Ecto.Migration

  def change do
    alter table(:hypervisors) do
      add(:fqdn, :string)
      add(:tls, :boolean, default: true)

      remove(:ip_address, :inet)
      remove(:webhook_endpoint, :string)
    end
  end
end
