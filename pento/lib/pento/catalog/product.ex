defmodule Pento.Catalog.Product do
  # The use macro injects code from the specified module into the current module.
  # Here, the generated code is giving the Product schema access to the functionality
  # implemented in the Ecto.Schema module. This includes access to the schema/1 function.
  use Ecto.Schema
  # The Product schema has access to Ecto’s changeset functionality,
  # thanks to the call to import Ecto.Changeset in the Pento.Catalog.Product module
  import Ecto.Changeset

  # schema/1 function creates an Elixir struct that weaves in fields from a database table
  schema "products" do
    field :description, :string
    field :name, :string
    field :sku, :integer
    field :unit_price, :float

    # The timestamps function means our code will also have :inserted_at and updated_at timestamps.
    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

end
