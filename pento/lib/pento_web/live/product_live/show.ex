# The show.ex file implements the LiveView module for a single product.
# It uses the show.html.heex template to render the HTML markup representing that product.
# I think this is when you click the product, not when you click edit as the edit part is handled by the modal part

defmodule PentoWeb.ProductLive.Show do
  use PentoWeb, :live_view

  alias Pento.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # I think this handle param is needed if you go the url directly, like
  # http://localhost:4000/products/2, so u need to populate the page with the correct product
  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Catalog.get_product!(id))}
  end

  # Private function that is called in handle_params
  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
