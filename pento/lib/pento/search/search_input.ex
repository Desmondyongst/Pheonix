defmodule Pento.Search.SearchInput do
    # A struct with :SKU field only
    defstruct [:sku]
    # A module attribute that stores a map of types our changeset is going to need
    @types %{sku: :string}
    import Ecto.Changeset

    # Note, user is just a parameter naming
    def changeset(%__MODULE__{} = user, attrs) do
      {user, @types}
      |> cast(attrs, Map.keys(@types))
      |> validate_required([:sku])
      |> validate_length(:sku, min: 7)
    end
end
