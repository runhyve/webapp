defmodule Webapp.Machines do
  @moduledoc """
  The Machines context.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Ecto.{
    Multi,
    Changeset
    }

  alias Webapp.{
    Hypervisors,
    Machines.Machine,
    Networks.Network
    }

  # Number of seconds after the create action is considered as failed.
  @create_timeout 180

  @doc """
  Returns the list of machines.

  ## Examples

      iex> list_machines()
      [%Machine{}, ...]

  """
  def list_machines(preloads \\ [:hypervisor, :plan]) do
    Repo.all(Machine)
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
  def get_machine!(id, preloads \\ [:hypervisor, :plan]) do
    Repo.get!(Machine, id)
    |> Repo.preload(preloads)
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
      |> Machine.changeset(attrs)

    if changeset.valid? do
      hypervisor =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> Hypervisors.get_hypervisor!

      module =
        ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
        |> String.to_atom()

      try do
        machine = Changeset.apply_changes(changeset)

        Multi.new()
        |> Multi.run(:hypervisor, module, :create_machine, [machine])
        |> Multi.run(:machine, fn _repo, %{hypervisor: job_id} ->
          changeset
          |> Changeset.put_change(:job_id, job_id)
          |> Repo.insert()
        end)
        |> Repo.transaction()
      rescue
        UndefinedFunctionError ->
          {:error, :hypervisor_not_found, changeset}
      end
    else
      Repo.insert(changeset)
    end
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
    machine
    |> Machine.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Machine.

  ## Examples

      iex> delete_machine(machine)
      {:ok, %Machine{}}

      iex> delete_machine(machine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_machine(%Machine{failed: true} = machine) do
    # Try to remove machine on server in silent mode.
    module = get_hypervisor_module(machine)
    try do
      apply(module, :delete_machine, [%{machine: machine}])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end

    Multi.new()
    |> Multi.delete(:machine, machine)
    |> Repo.transaction()
  end

  def delete_machine(%Machine{created: true} = machine) do
    module = get_hypervisor_module(machine)

    try do
      Multi.new()
      |> Multi.delete(:machine, machine)
      |> Multi.run(:hypervisor, module, :delete_machine, [])
      |> Repo.transaction()
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Updates a Machine status.
  """
  def update_machine_status(%Machine{} = machine) do
    module = get_hypervisor_module(machine)
    changeset = Machine.update_changeset(machine, %{})

    try do
      Multi.new()
      |> Multi.update(:machine, changeset)
      |> Multi.run(:hypervisor, module, :update_machine_status, [])
      |> Multi.run(:status, fn _repo, %{hypervisor: status} ->
        now =
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)


        changeset
        |> Changeset.put_change(:last_status, status)
        |> Changeset.put_change(:created_at, now)
        |> Changeset.put_change(:created, true)
        |> Repo.update()
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
  def update_status(%Machine{failed: true} = machine), do: {:ok, machine}

  # Machine is already created, simply check and update machine status.
  def update_status(%Machine{created: true} = machine) do
    check_machine_status(machine)
  end

  #
  def update_status(%Machine{failed: false, created: false, inserted_at: inserted_at} = machine)  do
    cond do
      NaiveDateTime.diff(NaiveDateTime.utc_now(), inserted_at) >= @create_timeout ->
        mark_as_failed(machine)
        {:error, "Something went wrong, your machine has been created for too long."}

      true ->
        check_job_status(machine)
    end
  end

  @doc """
  Check machine's job status.
  Returns machine struct or error message.
  """
  defp check_job_status(%Machine{} = machine) do
    case update_job_status(machine) do
      # Job is finished, check machine status this will update created flag.
      {:ok, %{"state" => "finished", "elevel" => 0}} ->
        check_machine_status(machine)

      {:ok, %{"state" => "finished", "elevel" => _elevel}} ->
        mark_as_failed(machine)
        {:error, "Machine was not created successfully"}

      {:ok, %{"state" => "blocked"}} ->
        mark_as_failed(machine)
        {:error, "Machine was not created successfully"}

      # Job is queued or still running
      {:ok, %{"state" => state}} ->
        {:ok, machine}

      {:error, :hypervisor_not_found} ->
        {:error, "Unable to check machine status"}

      {:error, error} ->
        {:error, error}
    end
  end

  defp mark_as_failed(%Machine{} = machine) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    Machine.update_changeset(machine, %{})
    |> Changeset.put_change(:last_status, "Failed")
    |> Changeset.put_change(:failed_at, now)
    |> Changeset.put_change(:failed, true)
    |> Repo.update()
  end

  @doc """
  Checks and updates machine status.
  Returns machine struct or error message.
  """
  defp check_machine_status(%Machine{} = machine) do
    case update_machine_status(machine) do
      {:ok, %{status: machine}} ->
        {:ok, machine}

      {:error, :hypervisor, error, _} ->
        cond do
          machine.created ->
            {:error, error}

          NaiveDateTime.diff(NaiveDateTime.utc_now(), machine.inserted_at) >= @create_timeout ->
            {:error, "Something went wrong, your machine has been created for too long."}

          true ->
            {:ok, machine}
        end

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
      |> Repo.transaction()
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Checks status of job related with given machine.
  """
  defp update_job_status(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      apply(module, :job_status, [machine.hypervisor, machine.job_id])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Starts a Machine.
  """
  def start_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      apply(module, :start_machine, [%{machine: machine}])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Stops a Machine.
  """
  def stop_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      apply(module, :stop_machine, [%{machine: machine}])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Performs hard stop of virtual machine.
  """
  def poweroff_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      apply(module, :poweroff_machine, [%{machine: machine}])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Opens a remote console for Machine.
  """
  def console_machine(%Machine{} = machine) do
    module = get_hypervisor_module(machine)

    try do
      apply(module, :console_machine, [%{machine: machine}])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
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
  def machine_can_do?(%Machine{failed: true} = machine, action), do: false
  def machine_can_do?(%Machine{created: false} = machine, action), do: false

  def machine_can_do?(%Machine{} = machine, action) do
    case action do
      :console ->
        machine.last_status == "Running" || machine.last_status == "Bootloader"

      :start ->
        machine.last_status != "Running" && machine.last_status != "Locked" &&
          machine.last_status != "Bootloader"

      :stop ->
        machine.last_status == "Running"

      :poweroff ->
        machine.last_status != "Stopped" && machine.last_status != "Creating"

      _ ->
        false
    end
  end

  @doc """
  Returns the module name of hypervisor type for given machine.
  """
  defp get_hypervisor_module(%Machine{} = machine) do
    hypervisor = Repo.preload(machine.hypervisor, :hypervisor_type)

    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
  end

end