defmodule Pento.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add(:name, :string)
      add(:postal_code, :integer)

      timestamps()
    end
  end
end
