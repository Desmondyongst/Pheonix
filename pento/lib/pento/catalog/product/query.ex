defmodule Pento.Catalog.Product.Query do
  import Ecto.Query
  alias Pento.Catalog.Product
  alias Pento.Survey.Rating

  def base, do: Product

  # This function is responsible for preloading user_ratings for the products
  def with_user_ratings(user) do
    base()
    |> preload_user_ratings(user)
  end

  def preload_user_ratings(query, user) do
    # It constructs a rating query, whichr etrieves the ratings associated with a given user
    ratings_query = Rating.Query.preload_user(user)

    # Then you preload the rating for association into query using the ratings query constructed earlier
    query
    |> preload(ratings: ^ratings_query)
  end
end
