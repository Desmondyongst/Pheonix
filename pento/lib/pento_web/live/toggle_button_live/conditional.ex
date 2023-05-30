defmodule PentoWeb.ToggleButtonLive.Conditional do
  use PentoWeb, :live_component

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:toggle, true)
    }
  end

  def handle_event("toggle", _params, %{assigns: %{toggle: toggle}} = socket) do
    # can just assign to socket here instead of sending to the parent
    {:noreply, socket |> assign(:toggle, !toggle)}
  end
end
