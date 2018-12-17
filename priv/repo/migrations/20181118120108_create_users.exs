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
      add(:email, :citext)
      add(:name, :string)
      add(:password_hash, :string)
      add(:confirmed_at, :utc_datetime)
      add(:reset_sent_at, :utc_datetime)
      add(:invited_at, :utc_datetime)
      add(:role, :user_role)

      timestamps()
    end

    create(unique_index(:users, [:email]))
  end
end
