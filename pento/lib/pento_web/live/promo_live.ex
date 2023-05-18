defmodule PentoWeb.PromoLive do
  use PentoWeb, :live_view
  alias Pento.Promo
  alias Pento.Promo.Recipient

  # We’ll use mount/3 to store a recipient struct and a changeset in the socket:
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_recipient()
     |> assign_changeset()
     |> assign_form()}
  end

  def assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{})
  end

  def assign_changeset(%{assigns: %{recipient: recipient}} = socket) do
    socket |> IO.inspect(label: "")

    socket
    |> assign(:changeset, Promo.change_recipient(recipient))
  end

  # In the book dont have this
  defp assign_form(%{assigns: %{changeset: changeset}} = socket) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("validate", %{"recipient" => recipient_params}, %{assigns: %{recipient: recipient}} = socket) do
    # I think can just do socket in the param then use socket.assigns.product
    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

      {:noreply,
        socket
        |> assign(:form, to_form(changeset))}
  end


  def handle_event("save", %{"recipient" => recipient_params}, %{assigns: %{recipient: recipient}} = socket) do
    # stub method
    case Promo.send_promo(recipient, recipient_params) do
      {:ok, _recipient} ->
        {:noreply,
         socket
         |> put_flash(:info, "Promo code sent successfully!")}

      # Normally error don't return recipient i think
      {:error, _recipient} ->
        {:noreply,
        socket
        |> put_flash(:error, "Error sending promo code!")}

    end

  end





end
