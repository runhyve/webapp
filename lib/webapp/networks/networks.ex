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
    Networks.Network,
    Networks.Ipv4,
    Networks.Ip_pool
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
    Repo.all(from(n in Network, where: n.id == ^network_ids))
    |> Repo.preload(preloads)
  end

  def list_networks_by_id(network_ids, preloads) when is_list(network_ids) do
    Repo.all(from(n in Network, where: n.id in ^network_ids))
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

    if changeset.valid? do
      hypervisor =
        Ecto.Changeset.get_change(changeset, :hypervisor_id)
        |> Hypervisors.get_hypervisor!()

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
  Returns the list of ip_pools.

  ## Examples

      iex> list_ip_pools()
      [%Ip_pool{}, ...]

  """
  def list_ip_pools(preloads \\ [:network]) do
    Repo.all(Ip_pool)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single ip_pool.

  Raises `Ecto.NoResultsError` if the Ip pool does not exist.

  ## Examples

      iex> get_ip_pool!(123)
      %Ip_pool{}

      iex> get_ip_pool!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ip_pool!(id, preloads \\ [:network]) do
    Repo.get!(Ip_pool, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a ip_pool and ipv4 for given range.

  ## Examples

      iex> create_ip_pool(%{field: value})
      {:ok, %Ip_pool{}}

      iex> create_ip_pool(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ip_pool(attrs \\ %{}) do
    multi =
      Multi.new()
      |> Multi.run(:ip_list, Webapp.Networks, :extract_ip_list, [attrs])
      |> Multi.insert(:ip_pool, Ip_pool.changeset(%Ip_pool{}, attrs))
      |> Multi.merge(fn %{ip_pool: ip_pool, ip_list: ip_list} ->
        list =
          Multi.new()
          |> add_ipv4_to_multi(ip_pool, ip_list)

        list
      end)
    Repo.transaction(multi)
  end

  def extract_ip_list(_repo, _multi_changes, %{"list" => list}) do
    list = String.split(list, ["\r", "\n", "\r\n"])
           |> Enum.filter(fn ip -> String.length(ip) > 4 end)
           |> Enum.map(fn ip -> String.trim(ip) end)
    {:ok, list}
  end


  def add_ipv4_to_multi(multi, _ip_pool, []), do: multi

  def add_ipv4_to_multi(multi, ip_pool, [ip | ip_list]) do
    # If gateway is in pool, mark it as reserved
    reserved = ip_pool.gateway.address ==  InetCidr.parse_address!(ip)

    ip_changeset = %Ipv4{}
                   |> Ipv4.changeset(%{ip_pool_id: ip_pool.id, ip: ip})
                   |> Changeset.put_change(:reserved, reserved)

    Multi.append(multi,
      Multi.new()
      |> Multi.insert("#{ip}", ip_changeset)
    )
    |> add_ipv4_to_multi(ip_pool, ip_list)
  end

  @doc """
  Updates a ip_pool.

  ## Examples

      iex> update_ip_pool(ip_pool, %{field: new_value})
      {:ok, %Ip_pool{}}

      iex> update_ip_pool(ip_pool, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ip_pool(%Ip_pool{} = ip_pool, attrs) do
    ip_pool
    |> Ip_pool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ip_pool changes.

  ## Examples

      iex> change_ip_pool(ip_pool)
      %Ecto.Changeset{source: %Ip_pool{}}

  """
  def change_ip_pool(%Ip_pool{} = ip_pool) do
    Ip_pool.changeset(ip_pool, %{})
  end

  @doc """
  Returns the first of unused ip addresses for given network.

  ## Examples

      iex> get_unused_ipv4(network)
      %Ipv4{}
  """
  def get_unused_ipv4(%Network{} = network) do
    Repo.one(
      from(ipv4 in Ipv4,
        join: i in assoc(ipv4, :ip_pool),
        join: n in assoc(i, :network),
        where: n.id == ^network.id and is_nil(ipv4.machine_id) and ipv4.reserved == false,
        limit: 1,
        order_by: [i.id, ipv4.ip]
      )
    )
  end

  @doc"""
  Marks the ipv4 as reserved.
  """
  def reserve_ipv4(%Ipv4{} = ipv4), do: change_ipv4_status(ipv4, true)

  @doc"""
  Removes reservation from the ipv4.
  """
  def release_ipv4(%Ipv4{} = ipv4), do: change_ipv4_status(ipv4, false)

  defp change_ipv4_status(%Ipv4{} = ipv4, status) do
    ipv4
    |> Changeset.change(%{reserved: status})
    |> Repo.update()
  end
end
