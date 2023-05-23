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
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />

        <%!-- This adds a “drag and drop” container to our form, where the phx-drop-target HTML attribute points
        to the @uploads.image.ref socket assignment. This is the ID that LiveView JavaScript uses to identify the
        file upload form field and tie it to the correct key in socket.assigns.uploads. --%>
        <div phx-drop-target={@uploads.image.ref}>
          <.label>Image</.label>
            <.live_file_input upload={@uploads.image} />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>

      </.simple_form>


      <%= for image <- @uploads.image.entries do %>
        <div class="mt-4">
          <.live_img_preview entry={image} width="60" />
        </div>
        <progress value={image.progress} max="100" />

        <%= for err <- upload_errors(@uploads.image, image) do %>
          <.error><%= err %></.error>
        <% end %>

        <%!-- button to cancel upload --%>
        <div>
          <%= for image <- @uploads.image.entries do %>
            <%!-- <%= inspect image%> --%>
            <%!-- If dont have {@myself}, it will call the handler in the parent live view --%>
            <.button phx-click="cancel-upload" phx-target={@myself} phx-value-ref={image.ref}> Cancel upload</.button>
          <% end %>
        </div>
      <% end %>

    </div>
    """
  end


  # Keep component up to date whenever either the parent live view or the component itself changes
  # The assigns attribute is a map containing the live_component attributes we provided: the title, action, product, and so on.
  # Update called when you assign something to the socket
  @impl true
  def update(%{product: product} = assigns = _passed_assigns, socket) do
    # assigns |>    IO.inspect(label: "assign")
    changeset = Catalog.change_product(product)

    # All that remains is to take the socket, drop in all of the attributes that we defined in the live_component tag, and add the new assignment to our changeset.
    {:ok,
     socket
    #  |> IO.inspect(label: "socket 1 ")
     |> assign(assigns)
    #  |> IO.inspect(label: "socket 2 ")

     |> assign_form(changeset)
     |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 9_000_000,
        auto_upload: true)}
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
    defp save_product(socket, :edit, params) do
      product_params = params_with_image(socket, params)
      case Catalog.update_product(socket.assigns.product, product_params) do
        {:ok, product} ->
          notify_parent({:saved, product})

          {:noreply,
           socket
           |> put_flash(:info, "Product updated successfully")
           |> push_patch(to: socket.assigns.patch)}

          # Error message inside changeset
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end

  defp save_product(socket, :new, params) do
    product_params = params_with_image(socket, params)

    case Catalog.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      # The %Ecto.Changeset{} is just to ptattern match and check that
      # we are passing in a changeset
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Function to save the image upload and add the saved image data to the product params.
  # It will need to consume any uploaded images, save them, and then return a list of product parameters including the image_upload path to the user.
  # We use a LiveView function called consume_uploaded_entries/3 to iterate through the list of entries in socket.assigns.uploads.image.entries and process each one with a custom
  # callback function, upload_static_file/2.
  def params_with_image(socket, params) do
    path = socket
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first
    Map.put(params, "image_upload", path)
  end

  defp upload_static_file(%{path: path}, _entry) do
    # Plug in your production image file persistence implementation here
    filename = Path.basename(path)
    dest = Path.join("priv/static/images", filename)
    # Copy the file to destination
    File.cp!(path, dest)


    {:ok, ~p"/images/#{filename}"}
  end

  # the ref key is specified in the render function of form_component.ex
  # where phx-value-ref={image.ref}, after the phx-value is just the key
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end


end
