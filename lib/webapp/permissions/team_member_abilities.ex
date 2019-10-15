alias Webapp.{
  Accounts.Member,
  Hypervioors.Machine,
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

  def can?(%Member{} = _member, _action, %Machine{} = _machine), do: false

  def can?(_member, _action, _model), do: false
end
