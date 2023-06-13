defmodule Pento.ShopContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.ShopContext` context.
  """

  @doc """
  Generate a shop.
  """
  def shop_fixture(attrs \\ %{}) do
    {:ok, shop} =
      attrs
      |> Enum.into(%{
        name: "some name",
        postal_code: "some postal_code"
      })
      |> Pento.ShopContext.create_shop()

    shop
  end
end
