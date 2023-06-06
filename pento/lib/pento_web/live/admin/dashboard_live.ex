defmodule PentoWeb.Admin.DashboardLive do
  use PentoWeb, :live_view
  alias PentoWeb.{Endpoint, Admin.SurveyResultsLive, Admin.UserActivityLive}
  @survey_results_topic "survey_results"
  @user_activity_topic "user_activity"

  def mount(_params, _session, socket) do
    # Remember, in the LiveView flow, mount/3 gets called twice—once when the live view first
    # mounts and renders as a static HTML response and again when the WebSocket-connected live view
    # process starts up. We’re calling subscribe/1 only if the socket is connected, in the second mount/3 call.
    if connected?(socket) do
      Endpoint.subscribe(@survey_results_topic)
      Endpoint.subscribe(@user_activity_topic)
    end

    {:ok,
     socket
     |> assign(:survey_results_component_id, "survey-results")
     |> assign(:user_activity_component_id, "user-activity")}
  end

  def handle_info(%{event: "rating_created_or_deleted"}, socket) do
    send_update(
      SurveyResultsLive,
      id: socket.assigns.survey_results_component_id
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(
      UserActivityLive,
      id: socket.assigns.user_activity_component_id
    )

    {:noreply, socket}
  end
end
