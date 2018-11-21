alias Webapp.{
  Accounts.User,
  Accounts.Group,
  Plans.Plan,
  Hypervisors.Hypervisor,
  Hypervioors.Machine,
  Hypervisors.Network
}

defimpl Canada.Can, for: User do
  def can?(%User{email: "piotr@runateam.com"}, _, _), do: true

  def can?(%User{}, _, Organisation), do: true

  def can?(_, _, _), do: false
end