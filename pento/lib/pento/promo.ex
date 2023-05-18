# This is the API (Boundary code)

defmodule Pento.Promo do
  alias Pento.Promo.Recipient

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  # Send_promo/2 is a placeholder for sending a promotional email.
  def send_promo(_recipient, _attrs) do
    # send email to promo recipient
    # {:error, %Recipient{}}
    # OR
    {:ok, %Recipient{}}
  end

end
