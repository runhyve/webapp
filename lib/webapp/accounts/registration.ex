defmodule Webapp.Accounts.Registration do
  use WebappWeb, :model

  alias Ecto.{Changeset, Multi}

  alias Webapp.{
    Repo,
    Accounts.Registration,
    Accounts.User,
    Accounts.Team,
    Accounts.Member,
    Types.UserRole
  }

  embedded_schema do
    field(:user_email, :string)
    field(:user_name, :string)
    field(:user_password, :string, virtual: true)

    field(:team_name, :string)
    field(:team_namespace, :string)
  end

  @required_fields ~w(user_email user_name user_password team_name team_namespace)a

  def changeset(%Registration{} = registration, attrs) do
    registration
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def registration(%{valid?: true} = changeset, attrs) do
    Multi.new()
    |> Multi.insert(:user, User.create_changeset(%User{}, extract_attrs("user", attrs)))
    |> Multi.insert(:team, Team.create_changeset(%Team{}, extract_attrs("team", attrs)))
    |> Multi.run(:membership, fn _repo, changes ->
      Member.create_changeset(
        %Member{user_id: changes.user.id, team_id: changes.team.id, role: "Administrator"},
        %{}
      )
      |> Repo.insert()
    end)
  end

  def registration(%{valid?: false} = changeset, _attrs) do
    Multi.new()
    |> Multi.error(:registration, %{errors: changeset.errors})
  end

  def copy_changeset_errors(%Changeset{} = from, %Changeset{} = to, field_prefix) do
    Enum.reduce(from.errors, to, fn {field, {msg, additional}} = foo, acc ->
      Ecto.Changeset.add_error(acc, String.to_existing_atom("#{field_prefix}_#{field}"), msg,
        additional: additional
      )
    end)
  end

  defp extract_attrs(field_prefix, attrs) do
    attrs
    |> Enum.map(fn {field, value} ->
      if String.match?("#{field}", ~r/#{field_prefix}/)  do
        field = String.trim_leading("#{field}", "#{field_prefix}_")
        {field, value}
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
    |> Map.new()
  end
end
