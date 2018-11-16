defmodule Webapp.Networks.Network do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors.Hypervisor,
    Machines.Machine
    }

  schema "networks" do
    field(:name, :string)
    field(:network, EctoNetwork.CIDR)

    belongs_to(:hypervisor, Hypervisor)
    many_to_many(:machines, Machine, join_through: "machines_networks")

    timestamps()
  end

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, [:name, :network, :hypervisor_id])
    |> validate_required([:name, :network, :hypervisor_id])
    |> validate_format(:name, ~r/^[a-zA-Z0-9_-]+$/,
      message: "Name must only contain letters and numbers and _ -"
    )
    |> unique_constraint(:name, name: :networks_name_hypervisor_id_index)
    |> assoc_constraint(:hypervisor)
  end
end
