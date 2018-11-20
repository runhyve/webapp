defmodule Webapp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute("""
      CREATE TYPE user_role AS ENUM (
        'Administrator',
        'User'
      )
    """)

    create table(:users) do
      add(:email, :string)
      add(:name, :string)
      add(:namespace_id, references(:namespaces, on_delete: :delete_all), null: false)
      add(:password_hash, :string)
      add(:confirmed_at, :utc_datetime)
      add(:reset_sent_at, :utc_datetime)
      add(:role, :user_role)

      timestamps()
    end

    create(index(:users, [:namespace_id]))
    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:name]))
  end
end
