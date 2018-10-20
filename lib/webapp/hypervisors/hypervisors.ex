defmodule Webapp.Hypervisors do
  @moduledoc """
  The Hypervisors context.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Webapp.Hypervisors.Type

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

  alias Webapp.Hypervisors.Machine

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

  ## Examples

      iex> create_machine(%{field: value})
      {:ok, %Machine{}}

      iex> create_machine(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_machine(attrs \\ %{}) do
    %Machine{}
    |> Machine.changeset(attrs)
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
    Repo.delete(machine)
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
end
