defmodule WebappWeb.DistributionView do
  use WebappWeb, :view
  alias WebappWeb.DistributionView

  def render("index.json", %{distributions: distributions}) do
    %{data: render_many(distributions, DistributionView, "distribution.json")}
  end

  def render("show.json", %{distribution: distribution}) do
    %{data: render_one(distribution, DistributionView, "distribution.json")}
  end

  def render("distribution.json", %{distribution: distribution}) do
    %{id: distribution.id,
      image: distribution.image,
      loader: distribution.loader,
      name: distribution.name,
      version: distribution.version}
  end
end
