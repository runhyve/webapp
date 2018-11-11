defmodule WebappWeb.NetworkView do
  use WebappWeb, :view

  import WebappWeb.MachineView, only: [hypervisors_select_options: 1]
end
