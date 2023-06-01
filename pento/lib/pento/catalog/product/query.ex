defmodule Pento.Catalog.Product.Query do
  import Ecto.Query
  alias Pento.Catalog.Product
  alias Pento.Survey.Rating
  alias Pento.Accounts.User
  alias Pento.Survey.Demographic
  alias Pento.Repo

  # :p is the alias for Product
  def base, do: from(Product, as: :p)
  # def base, do: Product

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

  def with_average_ratings(query \\ base()) do
    query
    |> join_ratings
    |> average_ratings
  end

  # The function takes a query parameter, which is typically an Ecto query representing a database query.
  # The query is piped into the join/5 function, which performs the inner join operation. The join/5 function is a macro provided by Ecto for performing table joins in database queries.
  # Within the join/5 function, we specify the type of join (:inner) and provide the necessary arguments. In this case, we join the Rating table (r) with the Product table (p).
  # The on option specifies the condition for the join, which is r.product_id == p.id. This condition ensures that the product_id column of the Rating table matches the id column of the Product table.
  defp join_ratings(query) do
    query |> join(:inner, [p: p], r in Rating, as: :r, on: r.product_id == p.id)
  end

  # Selects the product name and the average of its ratings' stars
  defp average_ratings(query) do
    query
    # Rebinding the product table alias p to p so that we can access p.id
    |> group_by([p: p], p.id)
    # Additionally, we use fragment("?::float", ...) to cast the average rating value to a float. This is done to ensure the result is returned as a float rather than an integer, as avg() function in some databases returns an integer.
    # We have access to p because we bind the result table of the join operation as r
    |> select([p: p, r: r], {p.name, fragment("?::float", avg(r.stars))})
  end

  def join_users(query \\ base()) do
    query
    |> join(:inner, [r: r], u in User, as: :u, on: r.user_id == u.id)
  end

  def join_demographics(query \\ base()) do
    query
    |> join(:inner, [u: u], d in Demographic, as: :d, on: d.user_id == u.id)
  end

  def filter_by_age_group(query \\ base(), filter) do
    query
    |> apply_age_group_filter(filter)
  end

  defp apply_age_group_filter(query, "18 and under") do
    birth_year = DateTime.utc_now().year - 18

    query
    |> where([d: d], d.year_of_birth >= ^birth_year)
  end

  defp apply_age_group_filter(query, "18 to 25") do
    birth_year_max = DateTime.utc_now().year - 18
    birth_year_min = DateTime.utc_now().year - 25

    query
    |> where(
      [d: d],
      d.year_of_birth >= ^birth_year_min and d.year_of_birth <= ^birth_year_max
    )
  end

  defp apply_age_group_filter(query, "25 to 35") do
    birth_year_max = DateTime.utc_now().year - 25
    birth_year_min = DateTime.utc_now().year - 35

    query
    |> where(
      [d: d],
      d.year_of_birth >= ^birth_year_min and d.year_of_birth <= ^birth_year_max
    )
  end

  defp apply_age_group_filter(query, "35 and up") do
    birth_year = DateTime.utc_now().year - 35

    query
    |> where([d: d], d.year_of_birth >= ^birth_year and d.year_of_birth <= ^birth_year)
  end

  # match with other filter such as "all"
  defp apply_age_group_filter(query, _filter) do
    query
  end

  def with_zero_ratings(query \\ base()) do
    query
    |> select([p], {p.name, 0})
  end

  # def query() do
  #   from(p in Product, as: :p)
  #   |> join(:inner, [p: p], r in Rating, on: p.id == r.product_id, as: :r)
  #   |> join(:inner, [r: r], u in User, as: :u, on: r.user_id == u.id)
  #   |> join(:inner, [u: u], d in Demographic, as: :d, on: d.user_id == u.id)
  #   |> group_by([p: p], [p.id])
  #   |> select([p: p, r: r], {p.name, fragment("?::float", avg(r.stars))})
  #   # put in functions
  #   |> where([d: d], d.year_of_birth >= ^(DateTime.utc_now().year - 18))
  # end
end
