defmodule PentoWeb.HtmlListLive.SingleItem do
  use Phoenix.Component

  attr(:item, :string, required: true)

  def render(assigns) do
    ~H"""
    <li><%= @item %></li>
    """
  end
end
