defmodule Pento.Catalog.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field :path, :string
    field :product_id, :id

    timestamps()
  end

  @doc false
  def changeset(product_image, attrs) do
    product_image
    |> cast(attrs, [:path])
    |> validate_required([:path])
  end
end
