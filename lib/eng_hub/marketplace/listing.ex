defmodule EngHub.Marketplace.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "listings" do
    field :title, :string
    field :description, :string
    field :price_or_exchange, :string
    field :status, :string
    field :project_id, :integer
    field :seller_id, Ecto.ULID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [:title, :description, :price_or_exchange, :status, :project_id, :seller_id])
    |> validate_required([:title, :description, :price_or_exchange, :status])
  end
end
