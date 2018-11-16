defmodule Webapp.Hypervisors.Hypervisor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hypervisors" do
    field(:name, :string)
    field(:ip_address, EctoNetwork.INET)
    field(:webhook_endpoint, :string)
    field(:webhook_token, :string)

    belongs_to(:hypervisor_type, Webapp.Hypervisors.Type)
    has_many(:machines, Webapp.Machines.Machine)
    has_many(:networks, Webapp.Networks.Network)

    timestamps()
  end

  @doc false
  def changeset(hypervisor, attrs) do
    hypervisor
    |> cast(attrs, [:name, :ip_address, :hypervisor_type_id, :webhook_endpoint, :webhook_token])
    |> validate_required([:name, :ip_address, :hypervisor_type_id, :webhook_endpoint, :webhook_token])
    |> assoc_constraint(:hypervisor_type)
    |> unique_constraint(:name)
  end
end
