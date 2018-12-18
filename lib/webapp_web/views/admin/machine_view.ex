defmodule WebappWeb.Admin.MachineView do
  use WebappWeb, :view
  import Webapp.Machines, only: [machine_can_do?: 2]
  import WebappWeb.MachineView, only: [map_status_to_css: 1, status_icon: 1]
end
