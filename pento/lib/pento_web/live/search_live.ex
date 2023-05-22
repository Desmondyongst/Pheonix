defmodule PentoWeb.SearchLive do
  use PentoWeb, :live_view
  alias Pento.Search
  alias Pento.Search.SearchInput

  # We will use mount/3 to store a recipient struct and a changeset in the socket:
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign_search_input()
      |> assign_changeset()
      |> assign_form()}
  end

  def assign_search_input(socket) do
    socket
    |> assign(:search_input, %SearchInput{})
  end

  def assign_changeset(%{assigns: %{search_input: search_input}} = socket) do
    socket
    |> assign(:changeset, Search.change_search_input(search_input))
  end

  # In the book dont have this
  defp assign_form(%{assigns: %{changeset: changeset}} = socket) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("validate", %{"search_input" => search_input_params}, %{assigns: %{search_input: search_input}} = socket) do
    changeset =
      search_input
      |> Search.change_search_input(search_input_params)
      |> Map.put(:action, :validate)

      {:noreply,
      socket
      |> assign(:form, to_form(changeset))}
  end

  def handle_event("save", %{"search_input" => search_input_params}, %{assigns: %{search_input: search_input}} = socket) do
    # stub method
    {key, msg} =
      case Search.start_search(search_input, search_input_params) do
        {:ok, _recipient} ->  {:info, "Search successful!"}
        {:error, _recipient} -> {:error, "There is no match found!"}
      end
      {:noreply, socket |> put_flash(key, msg)}
  end
end
