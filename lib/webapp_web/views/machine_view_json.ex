defmodule WebappWeb.MachineViewJSON do
  use WebappWeb, :view
  alias WebappWeb.MachineViewJSON

  def render("index.json", %{machines: machines}) do
    %{data: render_many(machines, MachineViewJSON, "machine.json")}
  end

  def render("show.json", %{machine: machine}) do
    %{data: render_one(machine, MachineViewJSON, "machine.json")}
  end

  def render("machine.json", %{machine: machine}) do
    %{id: machine.id}
  end
end
