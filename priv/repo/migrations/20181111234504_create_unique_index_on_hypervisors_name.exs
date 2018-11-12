defmodule Webapp.Repo.Migrations.CreateUniqueIndexOnHypervisorsName do
  use Ecto.Migration

  def change do
    create(unique_index(:hypervisors, [:name]))
  end
end
