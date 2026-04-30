defmodule EngHub.Communities.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "roles" do
    field :name, :string
    field :color, :string
    field :position, :integer, default: 0
    field :hoist, :boolean, default: false
    field :mentionable, :boolean, default: false
    field :permissions, :integer, default: 0

    belongs_to :server, EngHub.Communities.Server

    many_to_many :server_members, EngHub.Communities.ServerMember,
      join_through: "server_member_roles"

    timestamps(type: :utc_datetime)
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :color, :position, :hoist, :mentionable, :permissions, :server_id])
    |> validate_required([:name, :server_id])
  end
end
