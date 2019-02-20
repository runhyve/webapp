defmodule Webapp.Distributions do
  @moduledoc """
  The Distributions context.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Webapp.Distributions.Distribution

  @doc """
  Returns the list of distributions.

  ## Examples

      iex> list_distributions()
      [%Distribution{}, ...]

  """
  def list_distributions do
    Repo.all(Distribution)
  end

  @doc """
  Gets a single distribution.

  Raises `Ecto.NoResultsError` if the Distribution does not exist.

  ## Examples

      iex> get_distribution!(123)
      %Distribution{}

      iex> get_distribution!(456)
      ** (Ecto.NoResultsError)

  """
  def get_distribution!(id), do: Repo.get!(Distribution, id)

  @doc """
  Gets base name from image url
  """
  def get_img_name(%Distribution{} = distribution) do
    basename = Path.basename(distribution.image)
    Regex.replace(~r/\.(gz|tar.gz|xz|tgz)$/, basename, "")
  end

  @doc """
  Creates a distribution.

  ## Examples

      iex> create_distribution(%{field: value})
      {:ok, %Distribution{}}

      iex> create_distribution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_distribution(attrs \\ %{}) do
    %Distribution{}
    |> Distribution.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a distribution.

  ## Examples

      iex> update_distribution(distribution, %{field: new_value})
      {:ok, %Distribution{}}

      iex> update_distribution(distribution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_distribution(%Distribution{} = distribution, attrs) do
    distribution
    |> Distribution.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Distribution.

  ## Examples

      iex> delete_distribution(distribution)
      {:ok, %Distribution{}}

      iex> delete_distribution(distribution)
      {:error, %Ecto.Changeset{}}

  """
  def delete_distribution(%Distribution{} = distribution) do
    Repo.delete(distribution)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking distribution changes.

  ## Examples

      iex> change_distribution(distribution)
      %Ecto.Changeset{source: %Distribution{}}

  """
  def change_distribution(%Distribution{} = distribution) do
    Distribution.changeset(distribution, %{})
  end
end
