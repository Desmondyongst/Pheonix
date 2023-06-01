defmodule Pento.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Pento.Repo

  alias Pento.Catalog.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  def list_products_with_user_rating(user) do
    Product.Query.with_user_ratings(user)
    |> Repo.all()
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  # private name just to make it clearer what is the path
  def remove_product_image(%Product{image_upload: path = _path_to_be_deleted} = product) do
    # We remove from the database first then we remove the path
    product
    |> Product.remove_image_changeset()
    # use the updated changeset to update the repo
    |> Repo.update()
    |> case do
      {:ok, _updated_product} = ok ->
        # remove the file in the path
        filename = Path.basename(path)
        path = Path.join("priv/static/images", filename)
        # Copy the file to destination
        File.rm!(path)

        # the ok is the {:ok, p} as we assigned on top!!
        # if there is error File.rm! will throw an exception
        ok

      error ->
        error
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  # The \\ %{} syntax is used in the function parameter to provide a default value
  # for the attrs argument. It means that if the attrs argument is not provided when
  # calling the function, it will default to an empty map %{}.

  # Things to note when testing in iex, product need to be of type Product struct
  # Also, to update in repo, Product need to have the PKEY (id)
  # Also, make sure to do the necessary alias before calling the function

  @doc """
  Returns an %Ecto.Changeset{}` for tracking product changes.

   ## Examples

      iex> Pento.Catalog.markdown_product(Pento.Catalog.get_product!(1), %{unit_price: 7})
  """

  def markdown_product(%Product{} = product, attrs \\ %{}) do
    product
    |> Product.unit_price_changeset(attrs)
    |> Repo.update()
  end

  def products_with_average_ratings(%{age_group_filter: age_group_filter}) do
    Product.Query.with_average_ratings()
    |> Product.Query.join_users()
    |> Product.Query.join_demographics()
    # Note this age_group_filter passed into filter_by_age_group is not a map
    |> Product.Query.filter_by_age_group(age_group_filter)
    |> Repo.all()
  end

  def products_with_zero_ratings do
    Product.Query.with_zero_ratings()
    |> Repo.all()
  end
end
