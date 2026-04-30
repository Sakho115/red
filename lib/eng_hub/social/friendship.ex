defmodule EngHub.Social.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "friendships" do
    field :status, Ecto.Enum, values: [:pending_sent, :pending_received, :friends, :blocked]

    belongs_to :user, EngHub.Identity.User
    belongs_to :friend, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:user_id, :friend_id, :status])
    |> validate_required([:user_id, :friend_id, :status])
    |> unique_constraint([:user_id, :friend_id])
  end
end
