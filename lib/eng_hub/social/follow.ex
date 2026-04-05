defmodule EngHub.Social.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    belongs_to :follower, EngHub.Identity.User, type: Ecto.ULID
    belongs_to :following, EngHub.Identity.User, type: Ecto.ULID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:follower_id, :following_id])
    |> validate_required([:follower_id, :following_id])
    |> unique_constraint([:follower_id, :following_id], name: :follows_follower_following_index)
  end
end
