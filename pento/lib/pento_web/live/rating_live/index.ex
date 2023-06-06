defmodule PentoWeb.RatingLive.Index do
  use Phoenix.Component
  use Phoenix.HTML
  alias PentoWeb.RatingLive.Show
  alias PentoWeb.RatingLive

  attr(:products, :list, required: true)
  attr(:current_user, :any, required: true)
  attr(:index, :integer, required: true)

  # This is the function component that we'll call from parent live view to render the list of products
  # The function will take in an assigns argument containing the list of products and the current user
  # We will call this function from survey_live.html.heex
  def product_lists(assigns) do
    ~H"""
    <%!-- This is calling the heading function below  --%>
    <.heading products={@products} />
    <div class="grid grid-cols-2 gap-4 divide-y">
      <%!-- This line utilizes the :for attribute to iterate over @products using Enum.with_index/1.
      It assigns each element of @products to p and its index to i. --%>
      <%!-- product_rating is a function component below --%>
      <%!-- The function iterates over the elements of the enumerable and pairs each element with its index, starting from 0. --%>
    <.product_rating
      :for={{p, i} <- Enum.with_index(@products)}
      current_user={@current_user}
      product={p}
      index={i}
    />​
    </div>
    """
  end

  #  If all rating forms have been completed, we render the unicode for a checkmark
  def heading(assigns) do
    ~H"""
    <h2 class="font-medium text-2xl">
      <%!-- I think the if part is for the tick after the ratings word header --%>
      Ratings <%= if ratings_complete?(@products), do: raw("&#x2713;") %>
    </h2>
    """
  end

  def ratings_complete?(products) do
    Enum.all?(products, fn product ->
      not Enum.empty?(product.ratings)
    end)
  end

  # This is called for each product in a loop
  # ~H requires a variable named "assigns" to exist and be set to a map
  # @product refer to the assigns which is the parameter passed in
  def product_rating(%{product: %{ratings: ratings}} = assigns) do
    ~H"""
    <div><%= @product.name %></div>
    <%!-- I think if no rating, then will return nil which is falsy, else will return true  --%>
    <%!-- <%= inspect @product.ratings %> --%>

    <%!-- Alternative --%>
    <%!-- <%= if rating = List.first(@product.ratings) do %> --%>
    <%= if ratings |> Enum.empty?() do %>
      <div>
        <.live_component module={RatingLive.Form}
          id = {"rating-form-#{@product.id}"}
          product={@product}
          product_index={@index}
          current_user={@current_user} />
      </div>
    <% else %>
      <%!-- this is trying for livecomponent --%>
      <.live_component module={RatingLive.Show}
        id = {"rating-#{@product.id}"}
        product_index={@index}
        product={@product}
        rating={ratings |> List.first()}/>

      <%!-- <Show.stars rating={ratings |> List.first()} /> --%>
    <% end %>
    """
  end
end
