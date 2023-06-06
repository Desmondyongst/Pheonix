defmodule PentoWeb.Presence do
  # A presence model is the data structure that tracks information about active users on our site, and the functions that process changes in that model.
  use Phoenix.Presence,
    # This option specifies the OTP application associated with the presence module. It indicates that the pento OTP application is being used.
    otp_app: :pento,
    # This option specifies the PubSub server module to be used for communication between presence nodes. In this case, the Pento.PubSub module is used as the PubSub server.
    pubsub_server: Pento.PubSub

  # alias self including the config
  alias PentoWeb.Presence
  @user_activity_topic "user_activity"

  def track_user(pid, product, user_email) do
    Presence.track(pid, @user_activity_topic, product.name, %{users: [email: user_email]})
  end

  # Fetch the list of presences and shape them them into the correct format for rendering.
  def list_products_and_users do
    # list the present data for a given topic
    Presence.list(@user_activity_topic)
    |> Enum.map(&extract_product_with_users/1)
  end

  defp extract_product_with_users({product_name, %{metas: metas}}) do
    {product_name, users_from_metas_list(metas)}
  end

  defp users_from_metas_list(metas_list) do
    Enum.map(metas_list, &users_from_meta_map/1)
    # We flatten the results and we make them unique to account for any duplicate entries (for example, if the same user has the same product show page open in multiple tabs).
    |> List.flatten()
    |> Enum.uniq()
  end

  # Collect the key of :users key from each map
  def users_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
