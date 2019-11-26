defmodule WebappWeb.MachineControllerJSON do
  use WebappWeb, :controller

  alias Webapp.Machines
  alias Webapp.Machines.Machine

  action_fallback WebappWeb.FallbackController

  def index(conn, _params) do
    machines = Machines.list_machines()
    render(conn, "index.json", machines: machines)
  end

  def create(conn, %{"machine" => machine_params}) do
    with {:ok, %Machine{} = machine} <- Machines.create_machine(machine_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.machine_path(conn, :show, machine))
      |> render("show.json", machine: machine)
    end
  end

  def show(conn, %{"id" => id}) do
    machine = Machines.get_machine!(id)
    render(conn, "show.json", machine: machine)
  end

  def update(conn, %{"id" => id, "machine" => machine_params}) do
    machine = Machines.get_machine!(id)

    with {:ok, %Machine{} = machine} <- Machines.update_machine(machine, machine_params) do
      render(conn, "show.json", machine: machine)
    end
  end

  def delete(conn, %{"id" => id}) do
    machine = Machines.get_machine!(id)

    with {:ok, %Machine{}} <- Machines.delete_machine(machine) do
      send_resp(conn, :no_content, "")
    end
  end
end
