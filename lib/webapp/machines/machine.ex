defmodule Webapp.Machines.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors.Hypervisor,
    Plans.Plan,
    Networks,
    Networks.Ipv4,
    Networks.Network,
    Accounts.Team,
    Distributions.Distribution,
    Jobs.Job
  }

  # Machine name max length
  @machine_maxlen 255

  schema "machines" do
    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:name, :string)
    field(:last_status, :string)
    field(:ssh_public_key_id, :string, virtual: true)

    belongs_to(:job, Job)
    belongs_to(:hypervisor, Hypervisor)
    belongs_to(:plan, Plan)
    belongs_to(:distribution, Distribution)
    belongs_to(:team, Team)
    many_to_many(:networks, Network, join_through: "machines_networks")
    has_many(:ipv4, Ipv4)

    field(:created_at, :utc_datetime, default: nil)
    field(:failed_at, :utc_datetime, default: nil)
    field(:deleted_at, :utc_datetime, default: nil)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(machine, attrs) do
    network_ids = Map.get(attrs, "network_ids", [])
    networks = Networks.list_networks_by_id(network_ids)

    machine
    |> cast(attrs, [:name, :distribution_id, :hypervisor_id, :plan_id, :team_id])
    |> validate_required([:name, :distribution_id, :hypervisor_id, :plan_id, :team_id])
    |> unique_constraint(:name, name: :machines_name_team_id_index)
    |> assoc_constraint(:hypervisor)
    |> assoc_constraint(:plan)
    |> assoc_constraint(:team)
    |> assoc_constraint(:distribution)
    |> put_assoc(:networks, networks)
    |> validate_length(:networks, min: 1)
  end

  def create_changeset(machine, attrs) do
    network_ids = Map.get(attrs, "network_ids", [])
    networks = Networks.list_networks_by_id(network_ids)
    uuid = Ecto.UUID.generate()

    ipv4 =
      Enum.map(networks, fn network ->
        Networks.get_unused_ipv4(network)
      end)
      |> Enum.filter(fn ip -> ip end)

    machine
    |> cast(attrs, [
      :name,
      :distribution_id,
      :hypervisor_id,
      :plan_id,
      :team_id,
      :ssh_public_key_id
    ])
    |> validate_required([:name, :distribution_id, :hypervisor_id, :plan_id, :team_id])
    |> unique_constraint(:name, name: :machines_name_team_id_index)
    |> validate_name()
    |> put_change(:uuid, uuid)
    |> unique_constraint(:uuid)
    |> assoc_constraint(:hypervisor)
    |> assoc_constraint(:plan)
    |> assoc_constraint(:team)
    |> assoc_constraint(:distribution)
    |> put_assoc(:networks, networks)
    |> put_assoc(:ipv4, ipv4)
    |> validate_length(:networks, min: 1)
  end

  def networks_changeset(machine, networks) do
    machine
    |> cast(%{}, [])
    |> put_assoc(:networks, networks)
    |> validate_length(:networks, min: 1)
  end

  def update_changeset(machine, attrs) do
    machine
    |> cast(attrs, [:last_status, :job_id])
  end

  def mark_as_deleted_changeset(machine) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    name_suffix = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Integer.to_string()

    machine
    |> cast(%{}, [])
    |> put_change(:last_status, "Deleted")
    |> put_change(:deleted_at, now)
    |> put_change(:name, "deleted_#{name_suffix}_#{machine.name}")
  end

  def update_machine_changeset(machine, status) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    changeset = cast(machine, %{last_status: status}, [:last_status])

    changeset =
      if get_field(changeset, :created_at, nil) == nil do
        put_change(changeset, :created_at, now)
      else
        changeset
      end

    changeset
  end

  defp validate_name(changeset) do
    changeset
    |> validate_length(:name, max: @machine_maxlen)
    |> validate_format(
      :name,
      ~r/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/,
      message: "Name must only contain letters and numbers and . - "
    )
  end
end
