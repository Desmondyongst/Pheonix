defmodule Pento.Catalog.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pento.Catalog.Product

  schema "product_images" do
    field(:path, :string)
    belongs_to(:product, Product)

    timestamps()
  end

  @doc false
  def changeset(product_image, attrs) do
    product_image
    |> cast(attrs, [:product_id, :path])
    |> validate_required([:product_id, :path])
  end
end
