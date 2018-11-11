defmodule Webapp.Hypervisors.Network do
  use Ecto.Schema
  import Ecto.Changeset


  schema "networks" do
    field :name, :string
    field :network, EctoNetwork.CIDR

    belongs_to(:hypervisor, Webapp.Hypervisors.Hypervisor)

    timestamps()
  end

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, [:name, :network, :hypervisor_id])
    |> validate_required([:name, :network, :hypervisor_id])
    |> unique_constraint(:name)
    |> validate_format(:name, ~r/^[a-zA-Z0-9_-]+$/, message: "Name must only contain letters and numbers and _ -")
    |> assoc_constraint(:hypervisor)
  end

end
