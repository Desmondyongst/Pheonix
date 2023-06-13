defmodule PentoWeb.FinderLive do
  use PentoWeb, :live_view
  import Ecto.Query
  alias Pento.Repo
  alias Pento.Finder
  alias Pento.ShopContext
  alias Pento.ProductShop
  alias Pento.Catalog

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign_product_shop_pair()
    }
  end

  defp assign_product_shop_pair(socket) do
    socket
    |> stream(:product_shop, ShopContext.get_product_shop_pairs())
  end

  # NOTE: This is because we have both the :index and :new live_action for the same live_view
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # NOTE: params is determined by router.ex, how we specify the route (live("/finder/:id/edit", FinderLive, :edit) the route in this case params is {"id" => some_placeholder_value})
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product-Shop Pairing")
    |> assign(:product_shop, ShopContext.get_product_shop!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product-Shop Pairing")
    |> assign(:product_shop, %ProductShop{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Product-Shop Pairings")
    |> assign(:product_shop, nil)
  end

  # NOTE: This is for when the user submit the form and call `notify_parent({:saved, product_shop})`
  @impl true
  def handle_info({PentoWeb.FinderLive.FormComponent, {:saved, product_shop}}, socket) do
    # NOTE: Need to preload before updating if not the product and shop for the new product_shop will not be loaded
    {:noreply,
     socket
     |> stream_insert(:product_shop, product_shop |> Repo.preload([:product, :shop]))}
  end
end
