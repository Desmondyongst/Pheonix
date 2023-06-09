defmodule PentoWeb.Presence do
  # A presence model is the data structure that tracks information about active users on our site, and the functions that process changes in that model.
  use Phoenix.Presence,
    # NOTE:  This option specifies the OTP application associated with the presence module. It indicates that the pento OTP application is being used.
    otp_app: :pento,
    # NOTE:  This option specifies the PubSub server module to be used for communication between presence nodes. In this case, the Pento.PubSub module is used as the PubSub server.
    pubsub_server: Pento.PubSub

  # alias self including the config
  alias PentoWeb.Presence
  @user_activity_topic "user_activity"
  @survey_activity_topic "survey_activity"

  # NOTE: This part is for tracking the users on a product page

  def track_user(pid, product, user_email) do
    Presence.track(pid, @user_activity_topic, product.name, %{users: [email: user_email]})
  end

  # Fetch the list of presences and shape them them into the correct format for rendering.
  def list_products_and_users do
    # list the present data for a given topic
    Presence.list(@user_activity_topic)
    # |> IO.inspect(label: "This is the list of product and user")
    # NOTE: BEFORE Enum.map(&extract_product_with_users) is:
    # %{
    #   "New_Item" => %{
    #     metas: [
    #       %{phx_ref: "F2bcY7ZuWk999wpB", users: [email: "test5@gmail.com"]},
    #       %{phx_ref: "F2bcrzyBJbF99wfk", users: [email: "test4@gmail.com"]}
    #     ]
    #   }
    # }
    |> Enum.map(&extract_product_with_users/1)

    # NOTE: BEFORE Enum.map(&extract_product_with_users) is:
    # [{"New_Item", [email: "test5@gmail.com", email: "test4@gmail.com"]}]

    # |> IO.inspect(label: "This is the list of product and user after")
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

  # NOTE: This part is for tracking the number of people taking survey

  def track_survey_takers(pid, user_id) do
    Presence.track(pid, @survey_activity_topic, user_id, %{user_id: user_id})
  end

  # NOTE: We need the Enum.map to change into a list
  # NOTE: Note that extract_users function is called on each of the map due to the mapping function
  # before: %{
  #   "93" => %{metas: [%{phx_ref: "F2alRM5u-P-1eBjj", user_id: 93}]},
  #   "95" => %{metas: [%{phx_ref: "F2alYB9BQNK1eBwD", user_id: 95}]}
  # }
  # after: [
  #   {"93", %{metas: [%{phx_ref: "F2alRM5u-P-1eBjj", user_id: 93}]}},
  #   {"95", %{metas: [%{phx_ref: "F2alYB9BQNK1eBwD", user_id: 95}]}}
  # ]
  def list_users_on_survey do
    # QUESTION: This is a map, not a list, not sure why tho although it is called list
    Presence.list(@survey_activity_topic)
  end
end
