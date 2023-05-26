defmodule PentoWeb.DemographicLive.Form do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Demographic

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> assign_form()
    }
  end

  # Only has user_id field but is okay because we not validating using the changeset yet
  # Only when we try to handle the validate event then it will validate
  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(
      socket,
      :demographic,
      %Demographic{user_id: current_user.id}
    )
  end

  defp assign_form(%{assigns: %{demographic: demographic}} = socket) do
    assign(
      socket,
      :form,
      # Change demographic to changset and then to form
      to_form(Survey.change_demographic(demographic))
    )
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    # It's important to understand that assign/3 does not return a value itself.
    # Instead, it modifies the assigns map within the LiveView socket,
    # and the modified socket is then returned as part of the overall response from
    # the function that calls assign/3.
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    {:noreply, save_demograhic(socket, demographic_params)}
  end

  defp save_demograhic(socket, demographic_params) do
    # Create demographic will do repo.insert
    case Survey.create_demographic(demographic_params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        # If error, return socket with the updated changeset (contains the error)
        assign_form(socket, changeset)
    end
  end
end
