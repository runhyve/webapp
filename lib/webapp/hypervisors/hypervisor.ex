defmodule Webapp.Hypervisors.Hypervisor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hypervisors" do
    field(:name, :string)
    field(:fqdn, :string)
    field(:tls, :boolean, default: true)
    field(:webhook_token, :string)

    belongs_to(:hypervisor_type, Webapp.Hypervisors.Type)
    belongs_to(:region, Webapp.Regions.Region)
    has_many(:machines, Webapp.Machines.Machine)
    has_many(:networks, Webapp.Networks.Network)

    timestamps()
  end

  @doc false
  def changeset(hypervisor, attrs) do
    hypervisor
    |> cast(attrs, [:name, :fqdn, :tls, :hypervisor_type_id, :webhook_token, :region_id])
    |> validate_required([
      :name,
      :fqdn,
      :tls,
      :hypervisor_type_id,
      :region_id
    ])
    |> update_change(:webhook_token, fn
      nil -> hypervisor.webhook_token
      webhook_token -> webhook_token
    end)
    |> cleanup_fqdn()
    |> assoc_constraint(:hypervisor_type)
    |> assoc_constraint(:region)
    |> unique_constraint(:name)
  end

  def create_changeset(hypervisor, attrs) do
    hypervisor
    |> cast(attrs, [:name, :fqdn, :tls, :hypervisor_type_id, :webhook_token, :region_id])
    |> validate_required([
      :name,
      :fqdn,
      :tls,
      :hypervisor_type_id,
      :region_id,
      :webhook_token
    ])
    |> cleanup_fqdn()
    |> assoc_constraint(:hypervisor_type)
    |> assoc_constraint(:region)
    |> unique_constraint(:name)
  end

  defp cleanup_fqdn(changeset) do
    case fetch_change(changeset, :fqdn) do
      {:ok, fqdn} ->
        put_change(changeset, :fqdn, String.trim_trailing(fqdn, "/"))

      :error ->
        changeset
    end
  end
end
