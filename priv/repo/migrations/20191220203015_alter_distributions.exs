defmodule Webapp.Repo.Migrations.AlterDistributions do
    use Ecto.Migration
  
    def change do
        alter table(:distributions) do
          add(:archived_at, :utc_datetime, default: nil, null: true)
        end
    end
  end
