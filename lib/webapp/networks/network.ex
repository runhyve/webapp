defmodule Webapp.Networks.Network do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors.Hypervisor,
    Machines.Machine,
    Networks.Ip_pool
  }

  schema "networks" do
    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:name, :string)
    field(:network, EctoNetwork.CIDR)

    belongs_to(:hypervisor, Hypervisor)
    many_to_many(:machines, Machine, join_through: "machines_networks")
    has_many(:ip_pools, Ip_pool)
    has_many(:ipv4, through: [:ip_pools, :ipv4])

    timestamps(type: :utc_datetime)
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

  def create_changeset(network, attrs) do
    uuid = Ecto.UUID.generate()

    network
    |> cast(attrs, [:name, :network, :hypervisor_id])
    |> validate_required([:name, :network, :hypervisor_id])
    |> validate_format(:name, ~r/^[a-zA-Z0-9_-]+$/,
      message: "Name must only contain letters and numbers and _ -"
    )
    |> unique_constraint(:name, name: :networks_name_hypervisor_id_index)
    |> assoc_constraint(:hypervisor)
    |> put_change(:uuid, uuid)
    |> unique_constraint(:uuid)
  end
end
