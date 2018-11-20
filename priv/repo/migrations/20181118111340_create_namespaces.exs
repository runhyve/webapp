defmodule Webapp.Repo.Migrations.CreateNamespaces do
  use Ecto.Migration

  def change do
    create table(:namespaces) do
      add(:namespace, :string)
      add(:private, :boolean, default: false)
    end

    create(unique_index(:namespaces, [:namespace]))
  end
end
