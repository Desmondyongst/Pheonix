defmodule Pento.Survey.Demographic.Query do
  import Ecto.Query
  alias Pento.Survey.Demographic

  # In the given code snippet, the base/0 function simply returns the Demographic module itself,
  # which serves as the base query for retrieving Demographic records.

  # I think this is like SELECT * ?
  def base, do: Demographic

  # `d` alias is the alias for `Pento.Survey.Demographic`
  # d.user_id refers to the user_id field of a Demographic record.

  # `query`- This parameter is an optional Ecto query that represents the base query used to
  # retrieve Demographic records.
  # If no query is provided, the default base query defined in the base/0 function is used.
  def for_user(query \\ base(), user) do
    query
    |> where([d], d.user_id == ^user.id)
  end
end
