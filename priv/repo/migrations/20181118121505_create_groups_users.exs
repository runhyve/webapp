defmodule Webapp.Repo.Migrations.CreateGroupSUsers do
  use Ecto.Migration

  def change do
    create table(:groups_users) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:group_id, references(:groups, on_delete: :delete_all), null: false)
      add(:role, :user_role)
    end

    create(index(:groups_users, [:user_id]))
    create(index(:groups_users, [:group_id]))
  end
end
