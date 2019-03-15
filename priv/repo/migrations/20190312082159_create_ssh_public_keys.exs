defmodule Webapp.Repo.Migrations.CreateSshPublicKeys do
  use Ecto.Migration

  def change do
    create table(:ssh_public_keys) do
      add :title, :string
      add :ssh_public_key, :text
      add :fingerprint, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:ssh_public_keys, [:fingerprint, :user_id], name: :ssh_public_keys__user_id)
    create index(:ssh_public_keys, [:user_id])
  end
end