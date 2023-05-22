# Both index.ex and index.html.heex together implement a list of products.
# Since our live view doesn’t implement a render function, the behaviour will fall back to
# the default render/1 function and render the template that matches the name of the LiveView file,
# pento/pento_web/live/index.html.heex.



defmodule PentoWeb.ProductLive.Index do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias Pento.Catalog.Product


  # The @product assignment we added to the form component’s socket assigns will continue to track all of the product fields—name, description, and the like.
  # However, file upload configuration and the status of all uploads for the form will be tracked in a separate assignment, @uploads.
  # We need to call the allow_upload/3 function in update/2 function for live component and in mount for live view
  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :products, Catalog.list_products())}
    # {:ok,
    #   socket
    #   |> assign(:greeting, "Welcome to Pento!!")
    #   |> stream(:products, Catalog.list_products())
    # }
  end

  # The handle_params function’s job is to make any changes to the socket based on the requirements of the live_action.
  # The function is a behaviour callback that must return a :noreply tuple with the updated socket.
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  # `apply_action` will pattern match based on the live_action
  # This live view can handle different actions
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({PentoWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
