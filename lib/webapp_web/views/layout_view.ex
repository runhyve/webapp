defmodule WebappWeb.LayoutView do
  use WebappWeb, :view

  def version do
    "#{Application.spec(:webapp, :vsn)}-#{Mix.Project.config[:vcs_version]}"
  end
end
