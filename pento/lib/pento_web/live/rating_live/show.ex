# This is live component with removing rating button

# This is for if there is a rating for that product

defmodule PentoWeb.RatingLive.Show do
  use Phoenix.Component
  use Phoenix.HTML
  use PentoWeb, :live_component

  alias Pento.Survey

  attr(:rating, :any, required: true)

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- @rating is passed in from the caller --%>
    <%!-- raw() marks the given content as raw. This means any HTML code inside the given string won't be escaped. --%>
    <%!-- Enum.concat concatenates the HTML code for filled stars and unfilled stars --%>
    <%!-- Enum.join(" ") This joins the concatenated HTML code into a single string, separating the elements by a space. --%>
    <div style="padding-top: 15px">
      <%= @rating.stars
      |> filled_stars()
      |> Enum.concat(unfilled_stars(@rating.stars))
      |> Enum.join(" ")
      |> raw() %>

      <%!-- This is for trying live component --%>
      <.button
        phx-click="remove-rating"
        phx-target={@myself}
        phx-value-ref={@rating.id}
      >
        Remove Rating
      </.button>
    </div>
    """
  end

  def filled_stars(stars) do
    List.duplicate("&#x2605;", stars)
  end

  def unfilled_stars(stars) do
    List.duplicate("&#x2606;", 5 - stars)
  end

  @impl true
  def update(%{rating: rating} = assigns = _passed_assigns, socket) do
    # All that remains is to take the socket, drop in all of the attributes that we defined in the live_component tag, and add the new assignment to our changeset.
    {:ok,
     socket
     # assign the assigns to the socket so that we got product in the socket
     |> assign(assigns)
     |> assign(:rating, rating)}
  end

  # product_index
  def handle_event("remove-rating", %{"ref" => ref}, %{assigns: %{product_index: index}} = socket) do
    # The product_index is the socket is the one that changed/the one you clicked
    %{product_id: pid} = survey = Survey.get_rating!(ref)
    {:ok, _} = Survey.delete_rating(survey)
    send(self(), {:deleted_rating, {index, pid}})
    {:noreply, socket}
  end
end

# This is functional component without removing rating button

# # This is for if there is a rating for that product

# defmodule PentoWeb.RatingLive.Show do
#   use Phoenix.Component
#   use Phoenix.HTML

#   attr(:rating, :any, required: true)

#   def stars(assigns) do
#     ~H"""
#     <%!-- @rating is passed in from the caller --%>
#     <%!-- raw() marks the given content as raw. This means any HTML code inside the given string won't be escaped. --%>
#     <%!-- Enum.concat concatenates the HTML code for filled stars and unfilled stars --%>
#     <%!-- Enum.join(" ") This joins the concatenated HTML code into a single string, separating the elements by a space. --%>
#     <div><%=
#       @rating.stars
#       |> filled_stars()
#       |> Enum.concat(unfilled_stars(@rating.stars))
#       |> Enum.join(" ")
#       |> raw()
#       %></div>
#     """
#   end

#   def filled_stars(stars) do
#     List.duplicate("&#x2605;", stars)
#   end

#   def unfilled_stars(stars) do
#     List.duplicate("&#x2606;", 5 - stars)
#   end
# end
