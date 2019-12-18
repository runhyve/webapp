defmodule Webapp.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  import Webapp.Hypervisors, only: [get_hypervisor_module: 1]
  alias Webapp.Repo

  alias Ecto.{
    Multi,
    Changeset
    }

  alias Webapp.{
    Jobs.Job
  }

  @doc """
  Returns the list of job.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs(preloads \\ [:hypervisor]) do
    Job
    |> order_by(desc: :started_at)
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of active jobs..

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_active_jobs(preloads \\ [:hypervisor]) do
    Job
    |> where([j], j.last_status != "finished")
    |> Repo.all()
    |> Repo.preload(preloads)
  end


  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{source: %Job{}}

  """
  def change_job(%Job{} = job) do
    Job.changeset(job, %{})
  end

  @doc """
  Updates the job status.
  """
  def update_status(%Job{last_status: "finished"} = job), do: {:ok, job}

  def update_status(%Job{} = job) do
    module = get_hypervisor_module(job)

    try do
      Multi.new()
      |> Multi.run(:hypervisor, module, :job_status,  [job.hypervisor, job.ts_job_id])
      |> Multi.run(:job, __MODULE__, :update_job_status, [job])
      |> Repo.transaction()
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  def update_job_status(_repo, %{hypervisor: %{"state" => "finished", "elevel" => e_level}}, %Job{} = job) do
    now = DateTime.utc_now()
          |> DateTime.truncate(:second)

    update_job(job, %{"last_status" => "finished", "e_level" => e_level, "finished_at" => now})
  end

  def update_job_status(_repo, %{hypervisor: %{"state" => "queued"}}, %Job{} = job) do
    now = DateTime.utc_now()
          |> DateTime.truncate(:second)

    update_job(job, %{"last_status" => "queued", "updated_at" => now})
  end

  def update_job_status(_repo, %{hypervisor: %{"state" => "running"}}, %Job{} = job) do
    now = DateTime.utc_now()
          |> DateTime.truncate(:second)

    changeset = change_job(job)
                |> Changeset.put_change(:last_status, "running")

    changeset =
      if Changeset.get_field(changeset, :started_at, nil) == nil do
        Changeset.put_change(changeset, :started_at, now)
      else
        changeset
      end

    Repo.update(changeset)
  end

  def update_job_status(_repo, %{hypervisor: %{"state" => state}}, %Job{} = job) do
    update_job(job, %{"last_status" => state})
  end


#  case get_job_status(job) do
#    # Job is finished, check machine status this will update created flag.
#    {:ok, %{"state" => "finished", "elevel" => 0}} ->
#      check_machine_status(machine)
#
#    {:ok, %{"state" => "finished", "elevel" => _elevel}} ->
#      mark_as_failed(machine)
#      {:error, "Machine was not created successfully"}
#
#    {:ok, %{"state" => "blocked"}} ->
#      mark_as_failed(machine)
#      {:error, "Machine was not created successfully"}
#
#    # Job is queued or still running
#    {:ok, %{"state" => state}} ->
#      {:ok, machine}
#
#    {:error, :hypervisor_not_found} ->
#      {:error, "Unable to check machine status"}
#
#    {:error, error} ->
#      {:error, error}
#  end
end
