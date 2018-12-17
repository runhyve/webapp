alias Webapp.{
  Accounts.User,
  Accounts.Team,
  Plans.Plan,
  Hypervisors.Hypervisor,
  Hypervioors.Machine,
  Hypervisors.Network,
  Machines.Machine
}

defimpl Canada.Can, for: User do
  def can?(%User{role: "Administrator"}, _, _model), do: true

  def can?(%User{}, _action, _modele), do: false

  def can?(_user, _action, _model), do: false
end