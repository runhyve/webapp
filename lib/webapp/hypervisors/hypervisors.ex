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

  alias Webapp.{
    Hypervisors.Type,
    Hypervisors.Hypervisor,
    Machines.Machine,
    Networks.Network
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
  Returns the list of hypervisor's networks.

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
  Returns the list of hypervisor's machines.

  ## Examples

      iex> list_networks()
      [%Network{}, ...]

  """
  def list_hypervisor_machines(hypervisor) do
    hypervisor
    |> Ecto.assoc(:machines)
    |> Repo.all()
  end

  @doc """
  Gets a single hypervisor.

  Raises `Ecto.NoResultsError` if the Hypervisor does not exist.

  ## Examples

      iex> get_hypervisor!(123, [:machines])
      %Hypervisor{}

      iex> get_hypervisor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hypervisor!(id, preloads \\ []) do
    Repo.get!(Hypervisor, id)
    |> Repo.preload([:hypervisor_type] ++ preloads)
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
        name: "public",
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
  Returns the module name of hypervisor type for given hypervisor.
  """
  defp get_hypervisor_module(%Hypervisor{} = hypervisor) do
    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
  end
end
