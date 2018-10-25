defmodule Webapp.Hypervisors.Hypervisor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hypervisors" do
    field(:name, :string)
    field(:ip_address, :string)
    field(:webhook_endpoint, :string)

    belongs_to(:hypervisor_type, Webapp.Hypervisors.Type)
    has_many(:machines, Webapp.Hypervisors.Machine)

    timestamps()
  end

  @doc false
  def changeset(hypervisor, attrs) do
    hypervisor
    |> cast(attrs, [:name, :ip_address, :hypervisor_type_id, :webhook_endpoint])
    |> validate_required([:name, :ip_address, :hypervisor_type_id, :webhook_endpoint])
    |> validate_format(:ip_address, ~r/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)
    |> assoc_constraint(:hypervisor_type)
  end
end
