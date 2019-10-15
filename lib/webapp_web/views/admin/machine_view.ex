defmodule WebappWeb.Admin.MachineView do
  use WebappWeb, :view
  import WebappWeb.MachineView, only: [map_status_to_css: 1, status_icon: 1]

  def extract_ids(machines) do
    Enum.map(machines, fn machine ->
      machine.id
    end)
    |> Enum.join(",")
  end
end
