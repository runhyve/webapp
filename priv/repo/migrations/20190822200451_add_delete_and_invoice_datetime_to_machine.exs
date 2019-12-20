defmodule Webapp.Repo.Migrations.AddDeleteAndInvoiceDatetimeToMachine do
  use Ecto.Migration

  def up do
    alter table(:machines) do
      add(:deleted_at, :utc_datetime, default: nil, null: true)
      modify(:created_at, :utc_datetime, default: nil, null: true)
      modify(:failed_at, :utc_datetime, default: nil, null: true)

      remove(:created)
      remove(:failed)
    end
  end

  def down do
    alter table(:machines) do
      remove(:deleted_at)

      add(:created, :boolean)
      add(:failed, :boolean)
    end

  end
end
