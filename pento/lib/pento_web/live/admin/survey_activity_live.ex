defmodule PentoWeb.Admin.SurveyActivityLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_survey_activity()}
  end

  # fetch a list of products and their present users from PentoWeb.Presence, and assign it to the :user_activity key.
  def assign_survey_activity(socket) do
    socket
    |> assign(:survey_activity, Presence.list_users_on_survey())
  end
end
