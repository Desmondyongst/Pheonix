defmodule PentoWeb.Admin.DashboardLive do
  use PentoWeb, :live_view

  alias PentoWeb.{
    Endpoint,
    Admin.SurveyResultsLive,
    Admin.UserActivityLive,
    Admin.SurveyActivityLive
  }

  @survey_results_topic "survey_results"
  @user_activity_topic "user_activity"
  @survey_activity_topic "survey_activity"

  def mount(_params, _session, socket) do
    # Remember, in the LiveView flow, mount/3 gets called twice—once when the live view first
    # mounts and renders as a static HTML response and again when the WebSocket-connected live view
    # process starts up. We’re calling subscribe/1 only if the socket is connected, in the second mount/3 call.
    if connected?(socket) do
      # NOTE: This is for tracking the survey results
      Endpoint.subscribe(@survey_results_topic)
      # NOTE: This is for tracking the user activity on a specific product
      Endpoint.subscribe(@user_activity_topic)
      # NOTE: This is for tracking the user that is doing the survey
      Endpoint.subscribe(@survey_activity_topic)
    end

    {:ok,
     socket
     |> assign(:survey_results_component_id, "survey-results")
     |> assign(:user_activity_component_id, "user-activity")
     |> assign(:survey_activity_component_id, "survey_activity")}
  end

  # NOTE: Take note the difference in method signature here compared to the typical handle_info function
  def handle_info(%{event: "rating_created_or_deleted"}, socket) do
    send_update(
      SurveyResultsLive,
      id: socket.assigns.survey_results_component_id
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    # NOTE: This is to send update to update the number of active users viewing products
    send_update(
      UserActivityLive,
      id: socket.assigns.user_activity_component_id
    )

    # NOTE: This is to send update to update the number of active users at the survey page
    send_update(
      SurveyActivityLive,
      # NOTE: This id is assigned in dashboard_live.html.heex
      id: socket.assigns.survey_activity_component_id
    )

    {:noreply, socket}
  end
end
