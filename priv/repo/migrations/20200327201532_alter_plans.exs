defmodule Webapp.Repo.Migrations.AlterPlans do
    use Ecto.Migration
  
    def change do
        alter table(:plans) do
          add(:currency_code, :string, default: "USD", null: false)
          add(:period, :integer, default: 1, null: false)
          add(:period_unit, :string, default: "month", null: false)
        end
    end
  end
