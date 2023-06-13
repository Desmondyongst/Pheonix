defmodule Pento.ShopContextTest do
  use Pento.DataCase

  alias Pento.ShopContext

  describe "shops" do
    alias Pento.ShopContext.Shop

    import Pento.ShopContextFixtures

    @invalid_attrs %{name: nil, postal_code: nil}

    test "list_shops/0 returns all shops" do
      shop = shop_fixture()
      assert ShopContext.list_shops() == [shop]
    end

    test "get_shop!/1 returns the shop with given id" do
      shop = shop_fixture()
      assert ShopContext.get_shop!(shop.id) == shop
    end

    test "create_shop/1 with valid data creates a shop" do
      valid_attrs = %{name: "some name", postal_code: "some postal_code"}

      assert {:ok, %Shop{} = shop} = ShopContext.create_shop(valid_attrs)
      assert shop.name == "some name"
      assert shop.postal_code == "some postal_code"
    end

    test "create_shop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShopContext.create_shop(@invalid_attrs)
    end

    test "update_shop/2 with valid data updates the shop" do
      shop = shop_fixture()
      update_attrs = %{name: "some updated name", postal_code: "some updated postal_code"}

      assert {:ok, %Shop{} = shop} = ShopContext.update_shop(shop, update_attrs)
      assert shop.name == "some updated name"
      assert shop.postal_code == "some updated postal_code"
    end

    test "update_shop/2 with invalid data returns error changeset" do
      shop = shop_fixture()
      assert {:error, %Ecto.Changeset{}} = ShopContext.update_shop(shop, @invalid_attrs)
      assert shop == ShopContext.get_shop!(shop.id)
    end

    test "delete_shop/1 deletes the shop" do
      shop = shop_fixture()
      assert {:ok, %Shop{}} = ShopContext.delete_shop(shop)
      assert_raise Ecto.NoResultsError, fn -> ShopContext.get_shop!(shop.id) end
    end

    test "change_shop/1 returns a shop changeset" do
      shop = shop_fixture()
      assert %Ecto.Changeset{} = ShopContext.change_shop(shop)
    end
  end
end
