# This is the API (Boundary code)

defmodule Pento.Search do
  alias Pento.Search.SearchInput

  def change_search_input(%SearchInput{} = input, attrs \\ %{}) do
    SearchInput.changeset(input, attrs)
  end

  # start_search is a placeholder for doing search
  def start_search(_recipient, _attrs) do
    # Do search
    # {:error, %SearchInput{}}
    # OR
    {:ok, %SearchInput{}}
  end
end
