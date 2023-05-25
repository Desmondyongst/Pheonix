defmodule Pento.Survey.Rating.Query do
  # allow you to use the `where`
  import Ecto.Query
  alias Pento.Survey.Rating

  def base, do: Rating

  # I think this is not really a "preload" of the foreign key but more of to
  # get the rating associated with a user
  # The real preloading is done in `Pento.Catalog.Product.Query` where query |> preload...
  def preload_user(user) do
    base()
    |> for_user(user)
  end

  defp for_user(query, user) do
    query
    |> where([r], r.user_id == ^user.id)
  end
end
