defmodule Pento.Survey.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pento.Catalog.Product
  alias Pento.Accounts.User

  schema "ratings" do
    field(:stars, :integer)
    # take note: here is not field
    # it should be user. Think of :user as referring to the User table, then phoenix will automatically
    # :user_id in the changeset. If here is :user_id, then changeset will be user_id_id

    # First, we’ll update the schema to reflect that ratings belong to both users and products.
    # That way, we’ll have access to user and product fields, as well as the existing user_id and product_id fields on our Rating struct.

    belongs_to(:user, User)
    belongs_to(:product, Product)

    timestamps()
  end

  @doc false
  # def changeset(rating, attrs) do
  #   rating
  #   |> cast(attrs, [:stars, :user_id, :product_id])
  #   |> validate_required([:stars, :user_id, :product_id])
  #   |> validate_inclusion(:stars, 1..5)
  #   |> unique_constraint(:product_id, name: :index_ratings_on_user_product)
  # end

  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:stars, :user_id, :product_id])
    |> validate_required([:user_id, :product_id])
    |> validate_stars_selection()
    |> validate_inclusion(:stars, 1..5)
    |> unique_constraint(:product_id, name: :index_ratings_on_user_product)
  end

  defp validate_stars_selection(changeset) do
    selection = get_field(changeset, :stars)

    case selection do
      # If "Rating" is selected
      nil ->
        # OR THIS (RMB NEED REASSIGN!)
        # changeset = add_error(changeset, :stars, "Please select a rating!")

        changeset
        |> add_error(:stars, "Please select a rating!")

      _ ->
        changeset
        |> validate_required(:stars)
    end
  end
end
