defmodule Pento.ProductShop do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pento.Catalog.Product
  alias Pento.ShopContext.Shop

  schema "products_shops" do
    belongs_to(:product, Product)
    belongs_to(:shop, Shop)

    timestamps()
  end

  @doc false
  def changeset(product_shop, attrs) do
    product_shop
    |> cast(attrs, [:product_id, :shop_id])
    |> validate_required([:product_id, :shop_id])
    # NOTE: Customised error message for changeset
    |> unique_constraint([:product_id, :shop_id],
      message: "This Product-Shop pairing already exists in the database"
    )
  end
end
