defmodule EngHub.Communities.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "servers" do
    field :name, :string
    field :description, :string
    field :visibility, :string, default: "public"
    field :deleted_at, :utc_datetime
    field :settings, :map, default: %{}

    belongs_to :owner, EngHub.Identity.User
    has_many :members, EngHub.Communities.ServerMember
    has_many :categories, EngHub.Communities.Category
    has_many :channels, EngHub.Communities.Channel, foreign_key: :server_id

    timestamps(type: :utc_datetime)
  end

  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :description, :visibility, :owner_id, :deleted_at, :settings])
    |> validate_required([:name, :owner_id])
    |> validate_inclusion(:visibility, ["public", "private"])
  end
end
