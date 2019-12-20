defmodule Webapp.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors.Hypervisor
  }

  schema "jobs" do
    field :last_status, :string
    field :ts_job_id, :integer
    field(:e_level, :integer, default: nil)
    belongs_to(:hypervisor, Hypervisor)
    has_one(:machine, through: [:hypervisor, :machines])

    timestamps(type: :utc_datetime)
    field(:started_at, :utc_datetime, default: nil)
    field(:finished_at, :utc_datetime, default: nil)
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:hypervisor_id, :ts_job_id, :last_status, :e_level, :started_at, :finished_at])
    |> validate_required([:hypervisor_id, :ts_job_id])
    |> assoc_constraint(:hypervisor)
  end
end
