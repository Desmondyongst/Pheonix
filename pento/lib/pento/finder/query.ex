defmodule Pento.Finder.Query do
  # allow you to use the `where`
  import Ecto.Query

  alias Pento.ProductShop
  alias Pento.Repo
  alias Pento.Catalog.Product

  def base() do
    # NOTE: Cannot preload here
    ProductShop
  end

  def get_product_shop_pairs() do
    base()
  end
end
