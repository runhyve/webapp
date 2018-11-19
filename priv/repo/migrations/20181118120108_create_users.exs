defmodule Webapp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:name, :string)
      add(:password_hash, :string)
      add(:confirmed_at, :utc_datetime)
      add(:reset_sent_at, :utc_datetime)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:name]))
  end
end
