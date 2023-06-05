defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view

  alias PentoWeb.DemographicLive
  alias Pento.Survey
  alias Pento.Catalog

  alias PentoWeb.HtmlLive
  alias PentoWeb.HtmlListLive
  alias PentoWeb.RatingLive
  alias PentoWeb.ToggleButtonLive

  alias __MODULE__.Component

  # We need the current user in the socket, but `UserAuth.on_mount/4` function in user_auth.ex (which call mount_current_user) already added it to the
  # `sockets.assigns.user` key. So the socket already contains the :current_user key
  def mount(_params, _session, socket) do
    # leaving the socket unchanged
    {
      :ok,
      socket
      |> assign_demographic()
      |> assign_products()
    }
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(
      socket,
      :demographic,
      Survey.get_demographic_by_user(current_user)
    )
  end

  # This is the syntax for handle_info
  # def handle_info({:custom_message, payload}, socket) do
  # The return value of handle_info/2 should be a tuple with {:noreply, socket}
  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end

  def handle_info({:created_rating, updated_product, product_index}, socket) do
    {:noreply, handle_rating_created(socket, updated_product, product_index)}
  end

  def handle_info(
        {:deleted_rating, {index, pid}},
        %{assigns: %{products: products, current_user: user}} = socket
      ) do
    # |> assign_products()

    %{p: Catalog.get_product!(pid)} |> IO.inspect(label: "deleted_rating")

    {
      :noreply,
      socket
      # Or can assign_products() also can but not as lightweight
      # |> assign_products()
      |> assign(
        :products,
        List.replace_at(products, index, Catalog.get_product_with_user_rating(pid, user))
      )
      |> put_flash(:info, "Rating removed successfully")
    }
  end

  def handle_info({:created_toggle, toggle_new}, socket) do
    toggle_new
    |> IO.inspect(label: "handled info is called")

    {:noreply,
     socket
     |> assign(:toggle, toggle_new)}
  end

  # The handle_rating_created/3 reducer adds a flash message and updates the product
  # in place in the product list. This causes the template to re-render,
  # passing this updated product list to RatingLive.Index.product_list/1.
  # That function component in turn renders RatingLive.Index.product_rating/1,
  # which knows just what to do with a product that does contain a rating by the
  #  given user—it will render that rating’s details instead of a rating form.
  def handle_rating_created(
        %{assigns: %{products: products}} = socket,
        updated_product,
        product_index
      ) do
    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign(:products, List.replace_at(products, product_index, updated_product))
  end

  def assign_products(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :products, Catalog.list_products_with_user_rating(current_user))
  end
end
