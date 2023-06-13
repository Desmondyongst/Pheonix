defmodule Pento.Repo.Migrations.CreateProductsShops do
  use Ecto.Migration

  def change do
    create table(:products_shops) do
      add :product_id, references(:products, on_delete: :nothing)
      add :shop_id, references(:shops, on_delete: :nothing)

      timestamps()
    end

    create index(:products_shops, [:product_id])
    create index(:products_shops, [:shop_id])
  end
end
