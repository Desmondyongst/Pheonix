defmodule Pento.Promo.Recipient do
  # A struct with  :first_name and :email keys defines the attributes
  defstruct [:first_name, :email]
  # A module attribute stores a map of types our changeset is going to need.
  @types %{first_name: :string, email: :string}
  import Ecto.Changeset

  # Our changeset/2 function takes in a first argument of any Promo.Recipient struct,
  # pattern matched using the __MODULE__ macro which evaluates to the name of the current module.
  # It takes in a second argument of an attrs map.
  def changeset(%__MODULE__{} = user, attrs) do
    {user, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:first_name, :email])
    |> validate_format(:email, ~r/@/)
  end
end
