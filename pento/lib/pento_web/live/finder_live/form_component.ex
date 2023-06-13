# The form_component.ex file implements a new feature called a live component.
defmodule PentoWeb.FinderLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.Catalog
  alias Pento.Catalog.ProductImage
  alias Pento.ShopContext

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
      <%= @title %>
        <:subtitle>Use this form to manage Product-Shop pairing in the database</:subtitle>
      </.header>

      <%!-- “The for attribute passes the changeset holding the information for the form.” --%>
      <%!-- The `@form` is from the assign_form(changeset), where it is passed into the socket--%>
      <%!-- We’ll talk about the @myself assignment in Chapter 7 --%>
      <%!-- For now, know it’s a way to make sure events go to the form component and not the live view. --%>
      <%!-- Our code uses the phx-disable-with binding to configure the text of a disabled submit button. --%>
      <%!-- To enable the form for multipart use, add the miultipart attribute --%>
      <.simple_form
        for={@form}
        id="product-form"
        multipart
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <!-- # TODO: Display the option in more friendly method as a name instead and need to add the edit feature-->
        <div style="display: flex; justify-content: space-between">
          <.input
        field={@form[:product_id]}
        type="rating"
        prompt="Product Id"
        options={@product_options}
        />
          <.input
        field={@form[:shop_id]}
        type="rating"
        prompt="Shop Id"
        options={@shop_options}
        />

        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Pairing</.button>
        </:actions>

      </.simple_form>

    </div>
    """
  end

  # Keep component up to date whenever either the parent live view or the component itself changes
  # The assigns attribute is a map containing the live_component attributes we provided: the title, action, product, and so on.
  # Update called when you assign something to the socket
  @impl true
  def update(%{product_shop: product_shop} = assigns = _passed_assigns, socket) do
    # NOTE: Need to get the changeset from the db
    product_shop_pair = ShopContext.change_product_shop_pair(product_shop)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(product_shop_pair)
     # NOTE: Drop down option is assigned here instead of finder_live.ex
     |> assign_drop_down_options()}
  end

  defp assign_drop_down_options(socket) do
    socket
    |> assign(:product_options, Catalog.get_avail_product_options())
    |> assign(:shop_options, ShopContext.get_avail_shop_options())
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"product_shop" => product_shop_params}, socket) do
    changeset =
      socket.assigns.product_shop
      |> ShopContext.change_product_shop_pair(product_shop_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product_shop" => product_shop_params} = params, socket) do
    save_product_shop(socket, socket.assigns.action, product_shop_params)
  end

  # NOTE: WHICH SAVE_PRODUCT GET CALLED DEPENDS ON THE PATTERN MATCHING
  defp save_product_shop(socket, :edit, params) do
    case ShopContext.update_product_shop_pair(socket.assigns.product_shop, params) do
      {:ok, product_shop} ->
        notify_parent({:saved, product_shop})

        {:noreply,
         socket
         |> put_flash(:info, "Product-Shop Pairing updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      # Error message inside changeset
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product_shop(socket, :new, params) do
    case ShopContext.create_product_shop_pair(params) do
      {:ok, product_shop} ->
        notify_parent({:saved, product_shop})

        {:noreply,
         socket
         |> put_flash(:info, "Product-Shop Pairing created successfully")
         |> push_patch(to: socket.assigns.patch)}

      # The %Ecto.Changeset{} is just to ptattern match and check that
      # we are passing in a changeset
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
