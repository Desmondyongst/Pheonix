defmodule Pento.Catalog.Product do
  # The use macro injects code from the specified module into the current module.
  # Here, the generated code is giving the Product schema access to the functionality
  # implemented in the Ecto.Schema module. This includes access to the schema/1 function.
  use Ecto.Schema
  # The Product schema has access to Ecto’s changeset functionality,
  # thanks to the call to import Ecto.Changeset in the Pento.Catalog.Product module
  import Ecto.Changeset

  alias Pento.Survey.Rating
  alias Pento.Catalog.ProductImage

  # schema/1 function creates an Elixir struct that weaves in fields from a database table
  schema "products" do
    field(:description, :string)
    field(:name, :string)
    field(:sku, :integer)
    field(:unit_price, :float)
    # image_path
    field(:image_upload, :string)

    # The timestamps function means our code will also have :inserted_at and updated_at timestamps.
    timestamps()

    # We alias the new Rating schema and make use of it in the has_many relationship.
    # This will give us the ability to ask a given product for its ratings by calling product.ratings.
    has_many(:ratings, Rating)
    has_many(:product_images, ProductImage, on_replace: :delete)
  end

  @doc false
  def changeset(product, attrs) do
    # for it to be updated, is has to be inside the cast function

    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

  # NOTE: An changeset specifically for creation. Because we want to put_assoc but e.g. for test we still want to use
  # NOTE: the normal changeset.
  def create_or_update_changeset(product, %{"product_images" => product_images} = attrs) do
    # for it to be updated, is has to be inside the cast function
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
    # NOTE: put_assoc will help us insert into the product_images table
    |> put_assoc(:product_images, product_images)
  end

  # @doc
  # A changeset just to set the image_upload to nil
  # Return the updated changeset
  def remove_image_changeset(product), do: product |> change(image_upload: nil)

  def remove_product_image_changeset(
        %{product_images: product_images} = product,
        product_image_to_be_removed
      ) do
    product
    |> change(product_images: List.delete(product_images, product_image_to_be_removed))

    # product_images
    # |> IO.inspect(label: "before remove")
    # |> List.delete(product_image_to_be_removed)
    # |> IO.inspect(label: "after remove")
  end

  @doc false
  def unit_price_changeset(%{unit_price: current_price} = product, attrs) do
    # product |> IO.inspect(label: "")
    product
    |> cast(attrs, [:unit_price])
    |> validate_required([:unit_price])
    |> validate_number(:unit_price, less_than: current_price)
  end

  # Alternative method without mattern matching, seems to work based on my testing
  # @doc false
  # def unit_price_changeset(product, attrs) do
  #   product
  #   |> cast(attrs, [:unit_price])
  #   |> validate_required([:unit_price])
  #   |> validate_number(:unit_price, less_than: product.unit_price)
  # end
end
