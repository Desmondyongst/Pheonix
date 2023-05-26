defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view

  alias PentoWeb.DemographicLive
  alias Pento.Survey

  alias PentoWeb.HtmlLive
  alias PentoWeb.HtmlListLive

  alias __MODULE__.Component

  # We need the current user in the socket, but `UserAuth.on_mount/4` function in user_auth.ex (which call mount_current_user) already added it to the
  # `sockets.assigns.user` key. So the socket already contains the :current_user key
  def mount(_params, _session, socket) do
    # leaving the socket unchanged
    {:ok,
     socket
     |> assign_demographic}
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(
      socket,
      :demographic,
      Survey.get_demographic_by_user(current_user)
    )
  end

  # This is the syntax for handle_info
  # def handle_info({:custom_message, payload}, socket) do
  # The return value of handle_info/2 should be a tuple with {:noreply, socket}
  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end
end
