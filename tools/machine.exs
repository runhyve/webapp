defmodule Script do
  alias Webapp.{Hypervisors, Repo, Machines.Machine}

  def main(argv) do
    {options, args, _invalid} = OptionParser.parse(argv, strict: options())
    run(args, options)
  end

  # List of available options, used for help message.
  defp options do
    [
      machine: :integer,
      created: :bool,
      name: :string,
      plan: :integer,
      hypervisor: :integer,
      template: :string
    ]
  end

  # List of available commands, used for help message.
  defp commands do
    [
      ["list", "List all available machines", ""],
      ["add", "Add existing machine to webapp", "--name NAME --hypervisor ID --plan ID --template STRING"],
      ["update", "Updates machine with given fields", "--machine ID"]
    ]
  end

  @doc """
  List all machines.
  """
  def run(["list"], _options) do
    header = ["id", "name", "created", "last status", "hypervisor", "plan"]

    machines = Machines.list_machines()
    |> Enum.map(fn %Machines.Machine{} = machine ->
      [
        machine.id,
        machine.name,
        machine.created,
        machine.last_status,
        "#{machine.hypervisor.name}  (#{machine.hypervisor_id})",
        "#{machine.plan.name}  (#{machine.plan_id})"
      ]
    end)

    IO.puts TableRex.quick_render!(machines, header)
  end

  @doc """
  Add machine.
  """
  def run(["add"], options) do

    unless options[:name] do
      raise ArgumentError, message: "missing --name"
    end
    unless options[:hypervisor] do
      raise ArgumentError, message: "missing --hypervisor"
    end
    unless options[:plan] do
      raise ArgumentError, message: "missing --plan"
    end
    unless options[:template] do
      raise ArgumentError, message: "missing --template"
    end

    %Machine{last_status: "Creating"}
    |> Machine.changeset(%{
      name: options[:name],
      hypervisor_id: options[:hypervisor],
      plan_id: options[:plan],
      template: options[:template],
      created: true
    })
    |> Repo.insert()
  end

  @doc """
  Update machine.
  """
  def run(["update"], options) do
    IO.puts "updating machine with options"

    unless options[:machine] do
      raise ArgumentError, message: "missing --machine"
    end

    machine = Machines.get_machine!(options[:machine])
    changeset = Machines.change_machine(machine)

    changeset = if options[:created] do
      Ecto.Changeset.put_change(changeset, :created, String.to_atom(options[:created]))
    end

    Repo.update(changeset)
  end

  @doc """
  Unhandled argument with help message.
  """
  def run(_args, _options) do
    arguments = options()
    |> Enum.map(fn {k,v} -> "[--#{k} (#{v})]" end)
    |> Enum.join(" ")

    IO.puts "Usage: mix run tools/machine.exs #{arguments} <command>"
    IO.puts ""
    IO.puts "These are machine commands:"
    IO.puts TableRex.quick_render!(commands(), ["Command", "Description", "Mandatory options"])
  end
end

Script.main(System.argv)