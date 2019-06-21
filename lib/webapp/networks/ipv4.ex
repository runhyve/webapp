defmodule Webapp.Networks.Ipv4 do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]


  alias Webapp.{
    Machines.Machine,
    Networks.Ip_pool,
    Networks.Ipv4
  }

  schema "ipv4" do
    field(:ip, EctoNetwork.INET)
    field(:reserved, :boolean, default: false)
    belongs_to(:ip_pool, Ip_pool)
    belongs_to(:machine, Machine)

    timestamps()
  end

  @doc false
  def changeset(ip, attrs) do
    ip
    |> cast(attrs, [:ip, :ip_pool_id, :machine_id])
    |> validate_required([:ip, :ip_pool_id])
    |> assoc_constraint(:ip_pool)
    |> assoc_constraint(:machine)
  end

  def preload_ordered do
    from(ipv4 in Ipv4, order_by: ipv4.ip)
  end
end
