alias Webapp.{
  Accounts.User,
  Accounts.Team,
  Sessions.Session,
  Plans.Plan,
  Hypervisors.Hypervisor,
  Hypervioors.Machine,
  Hypervisors.Network,
  Machines.Machine
}

defimpl Canada.Can, for: User do
  def can?(%User{role: "Administrator"}, _, _model), do: true

  def can?(%User{} = user, :delete, %Session{} = session), do: user.id == session.user_id

  def can?(%User{} = current_user, _action, %User{} = user), do: current_user.id == user.id

  def can?(%User{}, _action, _model), do: false

  def can?(_user, _action, _model), do: false
end
