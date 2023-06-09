defmodule PentoWeb.Admin.SurveyResultsLive do
  use PentoWeb, :live_component
  use PentoWeb, :chart_live
  alias Pento.Catalog
  # alias Contex.Plot

  # The component’s update/2 callback will fire each time Admin.DashboardLive renders our component, so this is where we will add survey results data to component state.
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     # add the default age filter of "all"
     |> assign_age_group_filter()
     |> assign_gender_filter()
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  # NOTE: If the socket already has a value at either of the :age_group_filter or :gender_filter keys, then it should retain that value. Otherwise, it should set the default value to "all".
  # NOTE: the first time the key `age_group_filter` will be missing
  def assign_age_group_filter(%{assigns: %{age_group_filter: age_group_filter}} = socket) do
    socket
    |> assign(:age_group_filter, age_group_filter)
  end

  def assign_age_group_filter(socket) do
    socket
    |> assign(:age_group_filter, "all")
  end

  def assign_gender_filter(%{assigns: %{gender_filter: gender_filter}} = socket) do
    socket
    |> assign(:gender_filter, gender_filter)
  end

  def assign_gender_filter(socket) do
    socket
    |> assign(:gender_filter, "all")
  end

  defp assign_products_with_average_ratings(
         %{assigns: %{age_group_filter: age_group_filter, gender_filter: gender_filter}} = socket
       ) do
    socket
    |> assign(
      :products_with_average_ratings,
      # we want to pass in a map after we dereference from the socket
      get_products_with_average_ratings(%{
        age_group_filter: age_group_filter,
        gender_filter: gender_filter
      })
      # Catalog.products_with_average_ratings(%{age_group_filter: age_group_filter})
    )
  end

  defp get_products_with_average_ratings(%{
         age_group_filter: age_group_filter,
         gender_filter: gender_filter
       }) do
    # In Ecto, if you call Repo.all(query) where query is a query struct and there are no eligible rows matching the query conditions, the Repo.all/1 function will return an empty list ([]).
    case Catalog.products_with_average_ratings(%{
           age_group_filter: age_group_filter,
           gender_filter: gender_filter
         }) do
      [] ->
        Catalog.products_with_zero_ratings()

      products ->
        products
    end
  end

  def assign_dataset(
        %{assigns: %{products_with_average_ratings: products_with_average_ratings}} = socket
      ) do
    socket
    |> assign(
      :dataset,
      make_bar_chart_dataset(products_with_average_ratings)
    )
  end

  # defp make_bar_chart_dataset(data) do
  #   Contex.Dataset.new(data)
  # end

  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    socket
    |> assign(
      :chart,
      make_bar_chart(dataset)
    )
  end

  # defp make_bar_chart(dataset) do
  #   # The BarChart.new/1 creates a BarChart struct that describes how to plot the
  #   # bar chart
  #   Contex.BarChart.new(dataset)
  # end

  def assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(
      :chart_svg,
      # render_bar_chart(chart)
      render_bar_chart(chart, title(), subtitle(), x_axis(), y_axis())
    )
  end

  # defp render_bar_chart(chart) do
  #   Plot.new(500, 400, chart)
  #   |> Plot.titles(title(), subtitle())
  #   |> Plot.axis_labels(x_axis(), y_axis())
  #   |> Plot.to_svg()
  # end

  defp title do
    "Product Ratings"
  end

  defp subtitle do
    "average star ratings per product"
  end

  defp x_axis do
    "products"
  end

  defp y_axis do
    "stars"
  end

  # Our event handler responds by updating the age group filter in socket assigns and then re-invoking the rest of our reducer pipeline. The reducer pipeline will operate on the new age group filter to fetch an updated list of products with average ratings and construct the SVG chart with that updated list. Then, the template is re-rendered with this new state.
  def handle_event("age_group_filter", %{"age_group_filter" => age_group_filter}, socket) do
    {:noreply,
     socket
     |> assign_age_group_filter(age_group_filter)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  def assign_age_group_filter(socket, age_group_filter) do
    assign(socket, :age_group_filter, age_group_filter)
  end

  # Our event handler responds by updating the age group filter in socket assigns and then re-invoking the rest of our reducer pipeline. The reducer pipeline will operate on the new age group filter to fetch an updated list of products with average ratings and construct the SVG chart with that updated list. Then, the template is re-rendered with this new state.
  def handle_event("gender_filter", %{"gender_filter" => gender_filter}, socket) do
    {:noreply,
     socket
     |> assign_gender_filter(gender_filter)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  def assign_gender_filter(socket, gender_filter) do
    assign(socket, :gender_filter, gender_filter)
  end
end
