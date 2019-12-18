alias Webapp.{
  Accounts.User,
  Accounts.SSHPublicKey,
  Sessions.Session,
}

defimpl Canada.Can, for: User do
  def can?(%User{role: "Administrator"}, _, _model), do: true

  def can?(%User{} = user, :delete, %Session{} = session), do: user.id == session.user_id

  def can?(%User{} = user, :delete, %SSHPublicKey{} = ssh_public_key),
    do: user.id == ssh_public_key.user_id

  def can?(%User{} = user, :edit, %SSHPublicKey{} = ssh_public_key),
    do: user.id == ssh_public_key.user_id

  def can?(%User{} = user, :show, %SSHPublicKey{} = ssh_public_key),
    do: user.id == ssh_public_key.user_id

  def can?(%User{}, :index, SSHPublicKey), do: true
  def can?(%User{}, :new, SSHPublicKey), do: true
  def can?(%User{}, :create, SSHPublicKey), do: true

  def can?(%User{} = current_user, _action, %User{} = user), do: current_user.id == user.id

  def can?(%User{}, _action, _model), do: false

  def can?(_user, _action, _model), do: false
end
