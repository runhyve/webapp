alias Webapp.{
  Accounts.User,
  Accounts.Member,
  Accounts.Team,
  Plans.Plan,
  Hypervisors.Hypervisor,
  Hypervioors.Machine,
  Hypervisors.Network,
  Machines.Machine
}

defimpl Canada.Can, for: Member do

  def can?(%Member{}, :index, _model), do: true
  def can?(%Member{}, :new, _model), do: true
  def can?(%Member{}, :create, _model), do: true

  def can?(%Member{role: "Administrator"} = member, _action, %Machine{} = machine) do
    machine.team_id == member.team_id
  end

  def can?(%Member{} = member, :show, %Machine{} = machine) do
      machine.team_id == member.team_id
  end

  def can?(%Member{} = member, :console, %Machine{} = machine) do
    machine.team_id == member.team_id
  end

  def can?(%Member{} = member, :start, %Machine{} = machine) do
    machine.team_id == member.team_id
  end

  def can?(%Member{} = member, :stop, %Machine{} = machine) do
    machine.team_id == member.team_id
  end

  def can?(%Member{} = member, :poweroff, %Machine{} = machine) do
    machine.team_id == member.team_id
  end

  def can?(%Member{} = member, _action, %Machine{} = machine), do: false

  def can?(_member, _action, _model), do: false
end

defimpl Canada.Can, for: Atom do
  def can?(_member, _action, _model), do: false
end