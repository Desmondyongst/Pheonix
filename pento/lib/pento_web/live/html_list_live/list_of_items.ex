defmodule PentoWeb.HtmlListLive.ListOfItems do
  use Phoenix.Component

  alias PentoWeb.HtmlListLive.SingleItem

  # specify :list_of_items as a list
  attr(:list_of_items, :list, required: true)

  def render(assigns) do
    ~H"""
    <%= for item <- @list_of_items do %>
      <SingleItem.render item={item}>
      </SingleItem.render>
    <% end %>
    """
  end
end
