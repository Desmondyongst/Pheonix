defmodule Pento.ShopContext.Shop do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pento.Catalog.Product

  schema "shops" do
    field(:name, :string)
    field(:postal_code, :integer)

    many_to_many(:product, Product, join_through: "products_shops")

    timestamps()
  end

  @doc false
  def changeset(shop, attrs) do
    shop
    |> cast(attrs, [:name, :postal_code])
    |> validate_required([:name, :postal_code])
  end
end
