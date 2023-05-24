defmodule Pento.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :stars, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end

    # The create index code in the migration creates an index on a specific column or
    # set of columns in the specified table. Indexes are used to improve the performance
    # of database queries by allowing faster data retrieval.
    create index(:ratings, [:user_id])
    create index(:ratings, [:product_id])

    # Add the following unique index
    create unique_index(:ratings, [:user_id, :product_id],
    name: :index_ratings_on_user_product)

  end
end
