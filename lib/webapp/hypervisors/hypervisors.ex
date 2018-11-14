defmodule Webapp.Hypervisors do
  @moduledoc """
  The Hypervisors context.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Ecto.{
    Multi,
    Changeset
  }

  alias Webapp.Hypervisors.{
    Type,
    Hypervisor,
    Machine,
    Network
  }

  # Number of seconds after the create action is considered as failed.
  @create_timeout 180

  @doc """
  Returns the list of hypervisor_types.

  ## Examples

      iex> list_hypervisor_types()
      [%Type{}, ...]

  """
  def list_hypervisor_types do
    Repo.all(Type)
  end

  @doc """
  Gets a single type.

  Raises `Ecto.NoResultsError` if the Type does not exist.

  ## Examples

      iex> get_type!(123)
      %Type{}

      iex> get_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_type!(id), do: Repo.get!(Type, id)

  @doc """
  Creates a type.

  ## Examples

      iex> create_type(%{field: value})
      {:ok, %Type{}}

      iex> create_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_type(attrs \\ %{}) do
    %Type{}
    |> Type.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a type.

  ## Examples

      iex> update_type(type, %{field: new_value})
      {:ok, %Type{}}

      iex> update_type(type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_type(%Type{} = type, attrs) do
    type
    |> Type.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Type.

  ## Examples

      iex> delete_type(type)
      {:ok, %Type{}}

      iex> delete_type(type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_type(%Type{} = type) do
    Repo.delete(type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking type changes.

  ## Examples

      iex> change_type(type)
      %Ecto.Changeset{source: %Type{}}

  """
  def change_type(%Type{} = type) do
    Type.changeset(type, %{})
  end

  alias Webapp.Hypervisors.Hypervisor

  @doc """
  Returns the list of hypervisor.

  ## Examples

      iex> list_hypervisor()
      [%Hypervisor{}, ...]

  """
  def list_hypervisor do
    Repo.all(Hypervisor)
  end

  @doc """
  Gets a single hypervisor.

  Raises `Ecto.NoResultsError` if the Hypervisor does not exist.

  ## Examples

      iex> get_hypervisor!(123)
      %Hypervisor{}

      iex> get_hypervisor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hypervisor!(id) do
    Repo.get!(Hypervisor, id)
    |> Repo.preload(:hypervisor_type)
  end

  @doc """
  Check a hypervisor webhook health status.
  """
  def update_hypervisor_status(%Hypervisor{} = hypervisor) do
    module = get_hypervisor_module(hypervisor)

    try do
      apply(module, :hypervisor_status, [hypervisor])
    rescue
      UndefinedFunctionError -> {:error, :hypervisor_not_found}
    end
  end

  @doc """
  Creates a hypervisor.

  ## Examples

      iex> create_hypervisor(%{field: value})
      {:ok, %Hypervisor{}}

      iex> create_hypervisor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hypervisor(attrs \\ %{}) do
    hyperviosr =
      %Hypervisor{}
      |> Hypervisor.changeset(attrs)

    Multi.new()
    |> Multi.insert(:hypervisor, hyperviosr)
    |> Multi.run(:network, fn _repo, %{hypervisor: hypervisor} ->
      %Network{}
      |> Network.changeset(%{
        name: "#{hypervisor.name}-public",
        network: "0.0.0.0/32",
        hypervisor_id: hypervisor.id
      })
      |> Repo.insert()
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a hypervisor.

  ## Examples

      iex> update_hypervisor(hypervisor, %{field: new_value})
      {:ok, %Hypervisor{}}

      iex> update_hypervisor(hypervisor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hypervisor(%Hypervisor{} = hypervisor, attrs) do
    hypervisor
    |> Hypervisor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Hypervisor.

  ## Examples

      iex> delete_hypervisor(hypervisor)
      {:ok, %Hypervisor{}}

      iex> delete_hypervisor(hypervisor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hypervisor(%Hypervisor{} = hypervisor) do
    Repo.delete(hypervisor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hypervisor changes.

  ## Examples

      iex> change_hypervisor(hypervisor)
      %Ecto.Changeset{source: %Hypervisor{}}

  """
  def change_hypervisor(%Hypervisor{} = hypervisor) do
    Hypervisor.changeset(hypervisor, %{})
  end

  @doc """
  Returns the list of machines.

  ## Examples

      iex> list_machines()
      [%Machine{}, ...]

  """
  def list_machines do
    Repo.all(Machine)
    |> Repo.preload(:hypervisor)
    |> Repo.preload(:plan)
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
  def get_machine!(id) do
    Repo.get!(Machine, id)
    |> Repo.preload(:hypervisor)
    |> Repo.preload(:plan)
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
        |> get_hypervisor!

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
    |> Machine.changeset(attrs)
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
  def delete_machine(%Machine{} = machine) do
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
    changeset = change_machine(machine)

    try do
      Multi.new()
      |> Multi.update(:machine, changeset)
      |> Multi.run(:hypervisor, module, :update_machine_status, [])
      |> Multi.run(:status, fn _repo, %{hypervisor: status} ->
        changeset
        |> Changeset.put_change(:last_status, status)
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
  def check_status(%Machine{} = machine) do
    # Machine is not created, we need to check job status before fetching machine status.
    if !machine.created do
      # TODO: Add failure notifications
      case check_job_status(machine) do
        # Job is finished, check machine status this will update created flag.
        {:ok, %{"state" => "finished", "elevel" => 0}} ->
          check_machine_status(machine)

        {:ok, %{"state" => "finished", "elevel" => _elevel}} ->
          {:error, "Machine was not created successfully"}

        {:ok, %{"state" => "blocked"}} ->
          {:error, "Machine was not created successfully"}

        {:ok, %{"state" => state}} ->
          cond do
            NaiveDateTime.diff(NaiveDateTime.utc_now(), machine.inserted_at) >= @create_timeout ->
              {:error, "Something went wrong, your machine has been created for too long."}

            true ->
              {:ok, machine}
          end

        {:error, :hypervisor_not_found} ->
          {:error, "Unable to check machine status"}

        {:error, error} ->
          {:error, error}
      end

      # Machine is already created, simply check and update status.
    else
      check_machine_status(machine)
    end
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
  Checks status of job related with given machine.
  """
  defp check_job_status(%Machine{} = machine) do
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
    Machine.changeset(machine, %{})
  end

  @doc """
  Returns bool for given machine and operation if it's allowed.
  """
  def machine_can_do?(%Machine{} = machine, action) do
    case action do
      :console ->
        machine.last_status == "Running" || machine.last_status == "Bootloader"

      :start ->
        machine.created &&
          (machine.last_status != "Running" && machine.last_status != "Locked" &&
             machine.last_status != "Bootloader")

      :stop ->
        machine.last_status == "Running"

      :poweroff ->
        machine.last_status != "Stopped" && machine.last_status != "Creating"

      _ ->
        false
    end
  end

  @doc """
  Returns the list of networks.

  ## Examples

      iex> list_networks()
      [%Network{}, ...]

  """
  def list_networks do
    Repo.all(Network)
    |> Repo.preload(:hypervisor)
  end

  @doc """
  Returns the list of networks.

  ## Examples

      iex> list_networks()
      [%Network{}, ...]

  """
  def list_hypervisor_networks(hypervisor) do
    hypervisor
    |> Ecto.assoc(:networks)
    |> Repo.all()
  end

  @doc """
  Gets a single network.

  Raises `Ecto.NoResultsError` if the Network does not exist.

  ## Examples

      iex> get_network!(123)
      %Network{}

      iex> get_network!(456)
      ** (Ecto.NoResultsError)

  """
  def get_network!(id) do
    Repo.get!(Network, id)
    |> Repo.preload(:hypervisor)
  end

  @doc """
  Creates a network.

  ## Examples

      iex> create_network(%{field: value})
      {:ok, %Network{}}

      iex> create_network(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_network(attrs \\ %{}) do
    changeset =
      %Network{}
      |> Network.changeset(attrs)

    if changeset.valid? do
      hypervisor =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> get_hypervisor!

      module =
        ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
        |> String.to_atom()

      try do
        network = Changeset.apply_changes(changeset)

        Multi.new()
        |> Multi.run(:hypervisor, module, :create_network, [network])
        |> Multi.run(:network, fn _repo, _multi_changes ->
          changeset
          |> Repo.insert()
        end)
        |> Repo.transaction()
      rescue
        UndefinedFunctionError -> {:error, :hypervisor_not_found}
      end
    else
      Repo.insert(changeset)
    end
  end

  @doc """
  Updates a network.

  ## Examples

      iex> update_network(network, %{field: new_value})
      {:ok, %Network{}}

      iex> update_network(network, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_network(%Network{} = network, attrs) do
    network
    |> Network.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Network.

  ## Examples

      iex> delete_network(network)
      {:ok, %Network{}}

      iex> delete_network(network)
      {:error, %Ecto.Changeset{}}

  """
  def delete_network(%Network{} = network) do
    Repo.delete(network)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking network changes.

  ## Examples

      iex> change_network(network)
      %Ecto.Changeset{source: %Network{}}

  """
  def change_network(%Network{} = network) do
    Network.changeset(network, %{})
  end

  @doc """
  Returns the module name of hypervisor type for given hypervisor.
  """
  defp get_hypervisor_module(%Hypervisor{} = hypervisor) do
    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
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

  @doc """
  Returns the module name of hypervisor type for given machine.
  """
  defp get_hypervisor_module(%Network{} = network) do
    hypervisor = Repo.preload(network.hypervisor, :hypervisor_type)

    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
  end
end
