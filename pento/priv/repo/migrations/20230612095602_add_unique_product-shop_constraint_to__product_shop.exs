defmodule :"Elixir.Pento.Repo.Migrations.AddUniqueProduct-shopConstraintTo_ProductShop" do
  use Ecto.Migration

  def change do
    create(unique_index(:products_shops, [:product_id, :shop_id]))
  end
end
