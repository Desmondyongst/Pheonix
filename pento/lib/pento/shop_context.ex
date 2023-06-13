defmodule Pento.ShopContext do
  @moduledoc """
  The ShopContext context.
  """

  import Ecto.Query, warn: false
  alias Pento.Repo

  alias Pento.ShopContext.Shop
  alias Pento.Finder.Query
  alias Pento.ProductShop

  @doc """
  Returns the list of shops.

  ## Examples

      iex> list_shops()
      [%Shop{}, ...]

  """
  def list_shops do
    Repo.all(Shop)
  end

  def list_shops_in_ascending do
    from(s in Shop, order_by: [asc: s.id])
    |> Repo.all()
  end

  @doc """
  Gets a single shop.

  Raises `Ecto.NoResultsError` if the Shop does not exist.

  ## Examples

      iex> get_shop!(123)
      %Shop{}

      iex> get_shop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shop!(id), do: Repo.get!(Shop, id)

  @doc """
  Creates a shop.

  ## Examples

      iex> create_shop(%{field: value})
      {:ok, %Shop{}}

      iex> create_shop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shop(attrs \\ %{}) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shop.

  ## Examples

      iex> update_shop(shop, %{field: new_value})
      {:ok, %Shop{}}

      iex> update_shop(shop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shop(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shop.

  ## Examples

      iex> delete_shop(shop)
      {:ok, %Shop{}}

      iex> delete_shop(shop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shop(%Shop{} = shop) do
    Repo.delete(shop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shop changes.

  ## Examples

      iex> change_shop(shop)
      %Ecto.Changeset{data: %Shop{}}

  """
  def change_shop(%Shop{} = shop, attrs \\ %{}) do
    Shop.changeset(shop, attrs)
  end

  def get_avail_shop_options() do
    list_shops_in_ascending()
    |> Enum.map(fn row -> row.id end)
    |> Enum.uniq()
  end

  # NOTE: From here onwards is for `products_shops` join table
  def get_product_shop_pairs() do
    Query.get_product_shop_pairs()
    |> preload([:product, :shop])
    |> Repo.all()
  end

  def change_product_shop_pair(%ProductShop{} = product_shop, attrs \\ %{}) do
    ProductShop.changeset(product_shop, attrs)
  end

  def update_product_shop_pair(%ProductShop{} = product_shop, attrs) do
    product_shop
    |> ProductShop.changeset(attrs)
    |> Repo.update()
  end

  def create_product_shop_pair(attrs \\ %{}) do
    %ProductShop{}
    |> ProductShop.changeset(attrs)
    |> Repo.insert()
  end

  def get_product_shop!(id), do: Repo.get!(ProductShop, id)
end
