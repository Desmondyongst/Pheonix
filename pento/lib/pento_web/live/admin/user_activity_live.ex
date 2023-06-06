defmodule PentoWeb.Admin.UserActivityLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_user_activity()}
  end

  # fetch a list of products and their present users from PentoWeb.Presence, and assign it to the :user_activity key.
  def assign_user_activity(socket) do
    socket
    |> assign(:user_activity, Presence.list_products_and_users())
  end
end
