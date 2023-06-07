defmodule Pento.Repo.Migrations.CreateProductImages do
  use Ecto.Migration

  def change do
    create table(:product_images) do
      add(:path, :string)
      add(:product_id, references(:products, on_delete: :delete_all))

      timestamps()
    end

    create(index(:product_images, [:product_id]))
  end
end
