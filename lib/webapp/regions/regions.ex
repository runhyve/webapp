defmodule Webapp.Regions do
  @moduledoc """
  The Regions context.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Webapp.{
    Regions.Region,
    Hypervisors.Hypervisor
  }

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions do
    Repo.all(Region)
  end

  @doc """
  Returns the list of regions with at least one hypervisor.

  ## Examples

      iex> list_usable_regions()
      [%Region{}, ...]

  """
  def list_usable_regions do
    query = from(r in Region, [
      join: h in Hypervisor, on: r.id == h.region_id,
      group_by: r.id,
      where: h.is_inactive == false
    ])
    Repo.all(query)
  end

  @doc """
  Returns the list hypervisors associated with region.

  ## Examples

      iex> list_region_hypervisors()
      [%Hypervisor{}, ...]

  """
  def list_region_hypervisors(region, preloads \\ []) do
    from(h in Hypervisor,
      [where: h.is_inactive == false and h.region_id == ^region.id])
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id, preloads \\ []) do
     Repo.get!(Region, id)
     |> Repo.preload(preloads)
  end

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %Region{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %Region{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Region.

  ## Examples

      iex> delete_region(region)
      {:ok, %Region{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking region changes.

  ## Examples

      iex> change_region(region)
      %Ecto.Changeset{source: %Region{}}

  """
  def change_region(%Region{} = region) do
    Region.changeset(region, %{})
  end
end
