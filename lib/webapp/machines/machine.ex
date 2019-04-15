defmodule Webapp.Machines.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors,
    Hypervisors.Hypervisor,
    Plans.Plan,
    Networks,
    Networks.Network,
    Accounts.Team,
    Distributions.Distribution
  }

  # Machine name max length
  # @TODO: Change to UUID once https://github.com/churchers/vm-bhyve/issues/281 will be solved.
  @machine_maxlen 30

  schema "machines" do
    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:name, :string)
    field(:last_status, :string)
    field(:created, :boolean, default: false)
    field(:failed, :boolean, default: false)
    field(:job_id, :integer)
    field(:ssh_public_key_id, :string, virtual: true)

    belongs_to(:hypervisor, Hypervisor)
    belongs_to(:plan, Plan)
    belongs_to(:distribution, Distribution)
    belongs_to(:team, Team)
    many_to_many(:networks, Network, join_through: "machines_networks")

    field(:created_at, :naive_datetime)
    field(:failed_at, :naive_datetime)
    timestamps()
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
    |> put_assoc(:networks, networks)
    |> validate_length(:networks, min: 1)
  end

  def create_changeset(machine, attrs) do
    network_ids = Map.get(attrs, "network_ids", [])
    networks = Networks.list_networks_by_id(network_ids)
    uuid = Ecto.UUID.generate()

    machine
    |> cast(attrs, [:name, :distribution_id, :hypervisor_id, :plan_id, :team_id, :ssh_public_key_id])
    |> validate_required([:name, :distribution_id, :hypervisor_id, :plan_id, :team_id])
    |> unique_constraint(:name, name: :machines_name_team_id_index)
    |> validate_name()
    |> put_change(:uuid, uuid)
    |> unique_constraint(:uuid)
    |> assoc_constraint(:hypervisor)
    |> assoc_constraint(:plan)
    |> assoc_constraint(:team)
    |> put_assoc(:networks, networks)
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

  defp validate_name(changeset) do
    team_len =
      Ecto.Changeset.get_change(changeset, :team_id)
      |> Integer.to_string()
      |> String.length()

    changeset
    # Machine name is prefixed with "TEAMID_"
    |> validate_length(:name, max: 32 - team_len - 1)
    |> validate_format(:name, ~r/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/,
      message: "Name must only contain letters and numbers and . - "
    )
  end
end
