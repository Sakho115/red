defmodule EngHub.Communities.ServerMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "server_members" do
    field :role, :string, default: "member"

    belongs_to :user, EngHub.Identity.User
    belongs_to :server, EngHub.Communities.Server

    timestamps(type: :utc_datetime)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :server_id, :role])
    |> validate_required([:user_id, :server_id, :role])
    |> validate_inclusion(:role, ["owner", "admin", "member", "guest"])
    |> unique_constraint([:server_id, :user_id])
  end
end
