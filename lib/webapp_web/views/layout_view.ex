defmodule WebappWeb.LayoutView do
  use WebappWeb, :view

  def version do
    Application.spec(:webapp, :vsn)
  end
end
