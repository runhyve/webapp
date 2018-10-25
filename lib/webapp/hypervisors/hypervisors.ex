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
    Machine
  }

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
  Creates a hypervisor.

  ## Examples

      iex> create_hypervisor(%{field: value})
      {:ok, %Hypervisor{}}

      iex> create_hypervisor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hypervisor(attrs \\ %{}) do
    %Hypervisor{}
    |> Hypervisor.changeset(attrs)
    |> Repo.insert()
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
      %Machine{}
      |> Machine.changeset(attrs)

    if changeset.valid? do
      hypervisor =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> get_hypervisor!

      module =
        ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
        |> String.to_atom()

      try do
        Multi.new()
        |> Multi.insert(:machine, changeset)
        |> Multi.run(:hypervisor, module, :create_machine, [])
        |> Repo.transaction()
      rescue
        UndefinedFunctionError -> {:error, :hypervisor_not_found, changeset}
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
      |> Multi.run(:status, fn %{hypervisor: status} ->
        Changeset.put_change(changeset, :last_status, status)
        |> Repo.update()
      end)
      |> Repo.transaction()
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

  """
  Returns the module name of hypervisor type for given machine.
  """

  defp get_hypervisor_module(%Machine{} = machine) do
    hypervisor = Repo.preload(machine.hypervisor, :hypervisor_type)

    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
  end
end
