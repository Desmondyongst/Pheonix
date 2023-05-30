# This is for if there is no rating for the product

defmodule PentoWeb.RatingLive.Form do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Rating

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_rating()
     |> assign_form()}
  end

  defp assign_rating(%{assigns: %{current_user: user, product: product}} = socket) do
    assign(socket, :rating, %Rating{user_id: user.id, product_id: product.id})
  end

  defp assign_form(%{assigns: %{rating: rating}} = socket) do
    assign(socket, :form, to_form(Survey.change_rating(rating)))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    # It's important to understand that assign/3 does not return a value itself.
    # Instead, it modifies the assigns map within the LiveView socket,
    # and the modified socket is then returned as part of the overall response from
    # the function that calls assign/3.
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"rating" => rating_params}, socket) do
    changeset =
      socket.assigns.rating
      |> Survey.change_rating(rating_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"rating" => rating_params}, socket) do
    {:noreply, save_rating(socket, rating_params)}
  end

  # product_index passed from `product_rating` from index.ex
  defp save_rating(
         %{assigns: %{product_index: product_index, product: product}} = socket,
         rating_params
       ) do
    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        # a product struct is being updated by appending a new rating to the existing ratings field.
        product = %{product | ratings: [rating]}
        # self() returns the PID (process identifier) of the calling process.
        send(self(), {:created_rating, product, product_index})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end
end
