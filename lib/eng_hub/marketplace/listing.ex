defmodule EngHub.Marketplace.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "listings" do
    field :title, :string
    field :description, :string
    field :price_or_exchange, :string
    field :status, :string
    belongs_to :project, EngHub.Projects.Project
    belongs_to :seller, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [:title, :description, :price_or_exchange, :status, :project_id, :seller_id])
    |> validate_required([:title, :description, :price_or_exchange, :status])
  end
end
