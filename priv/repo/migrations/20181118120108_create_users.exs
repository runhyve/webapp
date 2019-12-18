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
      add(:password_hash, :string)
      add(:confirmed_at, :utc_datetime)
      add(:reset_sent_at, :utc_datetime)
      add(:invited_at, :utc_datetime)
      add(:role, :user_role)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:users, ["lower(email)"], name: :users_email_index))
  end
end
