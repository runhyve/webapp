defmodule Webapp.DNS do
  @moduledoc """
  The DNS context.
  """

  import Ecto.Query, warn: false
  alias Webapp.{Repo, RepoPanel}

  alias Ecto.{
    Multi,
    Changeset
  }

  alias Webapp.{
    DNS.Domain,
    DNS.Record
  }

  @doc """
  Returns the list of domains.

  ## Examples

      iex> list_domains()
      [%Domain{}, ...]

  """
  def list_domains do
    RepoPanel.all(Domain)
  end

  def list_domains(:paginate, params) do
    Domain
    |> order_by(asc: :name)
    |> RepoPanel.paginate(params)
  end

  @doc """
  Gets a single domain.

  Raises `Ecto.NoResultsError` if the Domain does not exist.

  ## Examples

      iex> get_domain!(123, [:records])
      %Domain{}

      iex> get_domain!(456)
      ** (Ecto.NoResultsError)

  """
  def get_domain!(id, preloads \\ []) do
    RepoPanel.get!(Domain, id)
    |> RepoPanel.preload(preloads)
  end
end