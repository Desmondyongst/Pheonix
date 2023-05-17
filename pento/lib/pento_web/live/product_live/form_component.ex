# The form_component.ex file implements a new feature called a live component.
defmodule PentoWeb.ProductLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <%!-- “The for attribute passes the changeset holding the information for the form.” --%>
      <%!-- The `@form` is from the assign_form(changeset), where it is passed into the socket--%>
      <%!-- We’ll talk about the @myself assignment in Chapter 7 --%>
      <%!-- For now, know it’s a way to make sure events go to the form component and not the live view. --%>
      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end


  # Keep component up to date whenever either the parent live view or the component itself changes
  # The assigns attribute is a map containing the live_component attributes we provided: the title, action, product, and so on.
  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)

    # All that remains is to take the socket, drop in all of the attributes that we defined in the live_component tag, and add the new assignment to our changeset.
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  # The first argument is the event name. For the first time, we use the metadata sent along with the event,
  # and we use it to pick off the form contents. The last argument to the event handler is the socket.
  # "product" is a attribute from <.live_component>
  def handle_event("save", %{"product" => product_params} = params, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  # Which save_product is called depends on the pattern matching
  defp save_product(socket, :edit, product_params) do
    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
