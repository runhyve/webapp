alias Webapp.{
  Accounts.User,
  Sessions.Session,
}

defimpl Canada.Can, for: Atom do
  # Registration
  def can?(nil, :new, User), do: true
  def can?(nil, :create, User), do: true
  def can?(nil, :confirm, User), do: true

  # Session
  def can?(nil, :new, Session), do: true
  def can?(nil, :create, Session), do: true

  def can?(_, _action, _model), do: false
end
