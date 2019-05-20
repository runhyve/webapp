defmodule WebappWeb.DistributionController do
  use WebappWeb, :controller

  alias Webapp.Distributions
  alias Webapp.Distributions.Distribution

  action_fallback WebappWeb.FallbackController

  def index(conn, _params) do
    distributions = Distributions.list_distributions()
    render(conn, "index.json", distributions: distributions)
  end

  def create(conn, %{"distribution" => distribution_params}) do
    with {:ok, %Distribution{} = distribution} <- Distributions.create_distribution(distribution_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.distribution_path(conn, :show, distribution))
      |> render("show.json", distribution: distribution)
    end
  end

  def show(conn, %{"id" => id}) do
    distribution = Distributions.get_distribution!(id)
    render(conn, "show.json", distribution: distribution)
  end

  def update(conn, %{"id" => id, "distribution" => distribution_params}) do
    distribution = Distributions.get_distribution!(id)

    with {:ok, %Distribution{} = distribution} <- Distributions.update_distribution(distribution, distribution_params) do
      render(conn, "show.json", distribution: distribution)
    end
  end

  def delete(conn, %{"id" => id}) do
    distribution = Distributions.get_distribution!(id)

    with {:ok, %Distribution{}} <- Distributions.delete_distribution(distribution) do
      send_resp(conn, :no_content, "")
    end
  end
end
