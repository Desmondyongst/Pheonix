# This is for Chapter 6 Your Turn Portion

defmodule PentoWeb.HtmlLive.ConfigMessage do
  use Phoenix.Component

  attr(:message, :string, required: true)

  def render(assigns) do
    ~H"""
    <h2>This is the fixed header</h2>
    <h3><%= @message %></h3>
    <h3 style="margin-bottom: 10px">
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end
end
