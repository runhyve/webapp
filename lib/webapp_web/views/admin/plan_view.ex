defmodule WebappWeb.Admin.PlanView do
  use WebappWeb, :view

  def period_unit_select_options do
    ["month", "year"]
  end
end
