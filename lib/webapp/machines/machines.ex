defmodule Webapp.Machines do
  @moduledoc """
  The Machines context.
  """

  import Ecto.Query, warn: false
  import Webapp.Hypervisors, only: [get_hypervisor_module: 1]
  alias Webapp.Repo

  alias Ecto.{
    Multi,
    Changeset
  }

  alias Webapp.{
    Notifications.Notifications,
    Hypervisors,
    Machines.Machine,
    Networks.Network,
    Accounts.Team,
    Jobs.Job
  }

  # Number of seconds after the create action is considered as failed.
  @create_timeout 300

  @doc """
  Returns the list of machines.

  ## Examples

      iex> list_machines()
      [%Machine{}, ...]

  """
  def list_machines(preloads \\ [:hypervisor, :plan, :job, :distribution]) do
    Machine
    |> order_by(asc: :name)
    |> where([m], is_nil(m.deleted_at))
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of team machines.

  ## Examples

      iex> list_team_machines(%Team{})
      [%Machine{}, ...]

  """
  def list_team_machines(%Team{} = team, preloads \\ [:hypervisor, :plan, :distribution]) do
    team
    |> Ecto.assoc(:machines)
    |> order_by(asc: :name)
    |> where([m], is_nil(m.deleted_at))
    |> where([m], m.last_status != "Deleting")
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single machine.

  Raises `Ecto.NoResultsError` if the Machine does not exist.

  ## Examples

      iex> get_machine!(123)
      %Machine{}

      iex> get_machine!(456)
      ** (Ecto.NoResultsError)

  """
  def get_machine!(id, preloads \\ [:hypervisor, :plan, :distribution]) do
    Repo.get!(Machine, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns unique id for hypervisor.
  """
  def get_machine_hid(%Machine{} = machine) do
    # TODO: replace to machine.uuid once bhyve will support more than 31 characters.
    "#{machine.team_id}_#{machine.name}"
  end

  @doc """
  Creates a machine.
  Executes the create_machine function in the Hypervisor module,
  and adds machine to the database if machine was initialised on Hypervisor.

  ## Examples

      iex> create_machine(%{field: value})
      {:ok, %Machine{}}

      iex> create_machine(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_machine(attrs) do
    # Validate machine changeset
    changeset =
      %Machine{last_status: "Creating"}
      |> Machine.create_changeset(attrs)

    if changeset.valid? do
      module =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> Hypervisors.get_hypervisor!()
        |> Hypervisors.get_hypervisor_module()

      try do
        machine = Changeset.apply_changes(changeset)

        Multi.new()
        |> Multi.run(:hypervisor, module, :create_machine, [machine])
        |> Multi.run(:job, __MODULE__, :multi_create_add_job, [machine])
        |> Multi.run(:machine, __MODULE__, :multi_create_machine, [changeset])
        |> Multi.run(:notify, Notifications, :publish, [:info, "Machine #{attrs["name"]} created successfuly"])
        |> Repo.transaction()
      rescue
        UndefinedFunctionError ->
          Notifications.publish(:critical, "Machine #{attrs["name"]} couldn't be created")
          {:error, :hypervisor_not_found, changeset}
      end
    else
      Repo.insert(changeset)
    end
  end

  def multi_create_add_job(_repo, %{hypervisor: job_id}, %Machine{} = machine) do
    %Job{}
    |> Job.changeset(%{"hypervisor_id" => machine.hypervisor_id, "ts_job_id" => job_id})
    |> Repo.insert()
  end

  def multi_create_machine(_repo, %{job: %Job{} = job}, changeset) do
    changeset
    |> Changeset.put_change(:job_id, job.id)
    |> Repo.insert()
  end

  @doc """
  Updates a machine.

  ## Examples

      iex> update_machine(machine, %{field: new_value})
      {:ok, %Machine{}}

      iex> update_machine(machine, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_machine(%Machine{} = machine, attrs) do
    result = machine
    |> Machine.update_changeset(attrs)
    |> Repo.update()

    Notifications.publish(:info, "Machine #{machine.name} updated successfuly")

    result
  end

  @doc """
  Deletes a Machine.

  ## Examples

      iex> delete_machine(machine)
      {:ok, %Machine{}}

      iex> delete_machine(machine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_machine(%Machine{failed_at: %DateTime{}} = machine) do
    # Try to remove machine on server in silent mode.
    module = get_hypervisor_module(machine)

    try do
      apply(module, :delete_machine, [machine])
    rescue
      UndefinedFunctionError ->
        {:error, :hypervisor_not_found}
    end

    Multi.new()
    |> Multi.update(:machine, Machine.mark_as_deleted_changeset(machine))
    |> Multi.run(:notify, Notifications, :publish, [:info, "Machine #{machine.name} deleted"])
    |> Repo.transaction()
  end

  def delete_machine(%Machine{created_at: %DateTime{}} = machine) do
    module = get_hypervisor_module(machine)

    try do
      Multi.new()
      |> Multi.run(:hypervisor, module, :delete_machine, [machine])
      |> Multi.run(:job, __MODULE__, :multi_delete_add_job, [machine])
      |> Multi.run(:machine, __MODULE__, :multi_delete_machine, [machine])
      |> Multi.run(:notify, Notifications, :publish, [:info, "Machine #{machine.name} has been marked for deletion"])
      |> Repo.transaction()
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't delete machine #{machine.name}")
        {:error, :hypervisor_not_found}
    end
  end

  def multi_delete_add_job(_repo, %{hypervisor: job_id}, %Machine{} = machine) when is_integer(job_id) do
    %Job{}
    |> Job.changeset(%{"hypervisor_id" => machine.hypervisor_id, "ts_job_id" => job_id})
    |> Repo.insert()
  end

  # Machine does not exists on the hypervisor, there is no task for deletion.
  def multi_delete_add_job(_repo, %{hypervisor: _job_id}, %Machine{}), do: {:ok, nil}

  # Machine does not exists on the hypervisor, mark as deleted.
  def multi_delete_machine(_repo, %{job: nil}, %Machine{} = machine) do
    Machine.mark_as_deleted_changeset(machine)
    |> Repo.update()
  end

  def multi_delete_machine(_repo, %{job: %Job{} = job}, %Machine{} = machine) do
    Machine.update_changeset(machine, %{"last_status" => "Deleting", "job_id" => job.id})
    |> Repo.update()
  end

  @doc """
  Updates a Machine status.
  """
  def update_machine_status(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      Multi.new()
      |> Multi.run(:hypervisor, module, :update_machine_status, [machine])
      |> Multi.run(:status, fn _repo, %{hypervisor: status} ->
        changeset = Machine.update_machine_changeset(machine, status)

        if Changeset.get_change(changeset, :last_status, false) do
          Notifications.publish(:info, "Machine #{machine.name} is now in state #{status}")
        end

        Repo.update(changeset)
      end)
      |> Repo.transaction()
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Checks machine status.
  Returns machine struct or error message.
  """
  def update_status(%Machine{failed_at: %DateTime{}} = machine), do: {:ok, machine}
  def update_status(%Machine{deleted_at: %DateTime{}} = machine), do: {:ok, machine}

  # There is no pending job, simply check machine status on the hypervisor.
  def update_status(%Machine{job_id: nil} = machine), do: check_machine_status(machine)

  # We need to wait.
  def update_status(%Machine{job: %Job{last_status: "queued"}} = machine), do: {:ok, machine}

  def update_status(%Machine{job: %Job{last_status: "running", started_at: started_at}} = machine) do
    if DateTime.diff(DateTime.utc_now(), started_at) >= @create_timeout do
      mark_as_failed(machine)
      {:error, "Something went wrong, creating virtual machine took too long."}
    else
      {:ok, machine}
    end
  end

  def update_status(%Machine{job: %Job{last_status: "blocked"}} = machine) do
    mark_as_failed(machine)
    {:error, "Machine was not created successfully"}
  end

  # The job was completed without errors, now we need to process it.
  def update_status(%Machine{last_status: "Creating", job: %Job{last_status: "finished", e_level: 0}} = machine) do
    {:ok, machine} = cleanup_job_id(machine)
    check_machine_status(machine)
  end

  def update_status(%Machine{last_status: "Deleting", job: %Job{last_status: "finished", e_level: 0}} = machine) do
    {:ok, machine} = cleanup_job_id(machine)
    Machine.mark_as_deleted_changeset(machine)
    |> Repo.update()

    {:ok, nil}
  end

  # The job was completed with errors, we need to handle it.
  def update_status(%Machine{last_status: "Creating", job: %Job{last_status: "finished", e_level: _e_level}} = machine) do
    mark_as_failed(machine)
    {:error, "Machine was not created successfully"}
  end

  def update_status(%Machine{last_status: "Deleting", job: %Job{last_status: "finished", e_level: _e_level}} = machine) do
    mark_as_failed(machine)
    {:error, "Machine was not deleted successfully"}
  end

  defp mark_as_failed(%Machine{} = machine) do
    now = DateTime.utc_now()
          |> DateTime.truncate(:second)

    Machine.update_changeset(machine, %{})
    |> Changeset.put_change(:last_status, "Failed")
    |> Changeset.put_change(:failed_at, now)
    |> Repo.update()
  end

  defp cleanup_job_id(%Machine{} = machine) do
    Machine.update_changeset(machine, %{})
    |> Changeset.put_change(:job_id, nil)
    |> Repo.update()
  end

  @doc """
  Checks and updates machine status.
  Returns machine struct or error message.
  """
  def check_machine_status(%Machine{} = machine) do
    case update_machine_status(machine) do
      {:ok, %{status: machine}} ->
        {:ok, machine}

      {:error, :hypervisor, _error, _} ->
        {:ok, machine}

      {:error, :hypervisor_not_found} ->
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Add a Network to Machine status.
  """
  def add_network_to_machine(%Machine{} = machine, %Network{} = network) do
    module = get_hypervisor_module(machine)
    changeset = Machine.networks_changeset(machine, machine.networks ++ [network])

    try do
      Multi.new()
      |> Multi.update(:machine, changeset)
      |> Multi.run(:hypervisor, module, :add_network_to_machine, [])
      |> Multi.run(:notify, Notifications, :publish, [:info, "Machine #{machine.name} is now connected to #{network.name}"])
      |> Repo.transaction()
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't connect machine #{machine.name} to network #{network.namae}")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Starts a Machine.
  """
  def start_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      result = apply(module, :start_machine, [%{machine: machine}])

      Notifications.publish(:info, "Machine #{machine.name} is being started")

      result
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Machine #{machine.name} couldn't be started")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Stops a Machine.
  """
  def stop_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      result = apply(module, :stop_machine, [%{machine: machine}])

      Notifications.publish(:info, "Machine #{machine.name} is being stopped")

      result
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't stop #{machine.name}")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Performs restart of virtual machine.
  """
  def restart_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      result = apply(module, :restart_machine, [%{machine: machine}])

      Notifications.publish(:info, "Machine #{machine.name} is being restarted")

      result
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't restart machine #{machine.name}")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Performs hard stop of virtual machine.
  """
  def poweroff_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      result = apply(module, :poweroff_machine, [%{machine: machine}])

      Notifications.publish(:info, "Machine #{machine.name} is being powered off")

      result
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't power off machine #{machine.name}")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Opens a remote console for Machine.
  """
  def console_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      result = apply(module, :console_machine, [%{machine: machine}])

      Notifications.publish(:info, "Console requested for machine #{machine.name}")

      result
    rescue
      UndefinedFunctionError ->
        Notifications.publish(:critical, "Couldn't open open console to machine #{machine.name}")
        {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking machine changes.

  ## Examples

      iex> change_machine(machine)
      %Ecto.Changeset{source: %Machine{}}

  """
  def change_machine(%Machine{} = machine) do
    Machine.update_changeset(machine, %{})
  end

  @doc """
  Returns bool for given machine and operation if it's allowed.
  """
  def machine_can_do?(%Machine{failed_at: %DateTime{}} = _machine, :delete), do: true

  def machine_can_do?(%Machine{deleted_at: %DateTime{}} = _machine, _action), do: false
  def machine_can_do?(%Machine{failed_at: %DateTime{}} = _machine, _action), do: false

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def machine_can_do?(%Machine{created_at: %DateTime{}} = machine, action) do
    case action do
      :console ->
        machine.last_status == "Running" || machine.last_status == "Bootloader"

      :start ->
        machine.last_status != "Running" &&
          machine.last_status != "Bootloader" && machine.last_status != "Deleting"

      :stop ->
        machine.last_status == "Running" || machine.last_status == "Bootloader"

      :restart ->
        machine.last_status == "Running" || machine.last_status == "Bootloader"

      :poweroff ->
        machine.last_status != "Stopped" && machine.last_status != "Creating" &&
          machine.last_status != "Deleting"

      :delete ->
        machine.last_status != "Creating" && machine.last_status != "Deleting"
      _ ->
        false
    end
  end

  def machine_can_do?(%Machine{}, _action), do: false
end
