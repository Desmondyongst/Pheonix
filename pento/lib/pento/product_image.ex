defmodule Pento.ProductImage do
  @moduledoc """
  The ProductImage context.
  """

  import Ecto.Query, warn: false
  alias Pento.Repo
  alias Pento.Catalog.ProductImage

  @doc """
  Gets a single product image.

  Raises `Ecto.NoResultsError` if the product image does not exist.

  """
  def get_product_image!(id) do
    Repo.get!(ProductImage, id)
  end
end
