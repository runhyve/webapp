defmodule Webapp.Networks do
  @moduledoc """
  The Networks context.
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

  @doc """
  Returns the list of networks.

  ## Examples

      iex> list_networks()
      [%Network{}, ...]

  """
  def list_networks(preloads \\ [:hypervisor]) do
    Repo.all(Network)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of networks by given ids.

  ## Examples

      iex> list_networks_by_id([1,2,3])
      [%Network{}, ...]

  """
  def list_networks_by_id(network_ids, preloads \\ [])
  def list_networks_by_id(network_ids, preloads) when is_binary(network_ids) do
    Repo.all(from n in Network, where: n.id == ^network_ids)
    |> Repo.preload(preloads)
  end
  def list_networks_by_id(network_ids, preloads) when is_list(network_ids) do
    Repo.all(from n in Network, where: n.id in ^network_ids)
    |> Repo.preload(preloads)
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
  def get_network!(id, preloads \\ [:hypervisor]) do
    Repo.get!(Network, id)
    |> Repo.preload([preloads])
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

    IO.inspect(changeset)

    if changeset.valid? do
      hypervisor =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> Hypervisors.get_hypervisor!

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
        UndefinedFunctionError ->
          {:error, :hypervisor_not_found}
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
  Returns the module name of hypervisor type for given machine.
  """
  defp get_hypervisor_module(%Network{} = network) do
    hypervisor = Repo.preload(network.hypervisor, :hypervisor_type)

    module =
      ("Elixir.Webapp.Hypervisors." <> String.capitalize(hypervisor.hypervisor_type.name))
      |> String.to_atom()
  end
end