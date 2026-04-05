defmodule EngHub.Repo.Migrations.CreateListings do
  use Ecto.Migration

  def change do
    create table(:listings) do
      add :title, :string
      add :description, :text
      add :price_or_exchange, :string
      add :status, :string
      add :seller_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:listings, [:seller_id])
  end
end
