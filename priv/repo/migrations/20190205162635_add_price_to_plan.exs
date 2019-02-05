defmodule Webapp.Repo.Migrations.AddPriceToPlan do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add(:price, :integer)
    end
    
  end
end
