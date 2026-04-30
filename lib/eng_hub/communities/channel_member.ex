defmodule EngHub.Communities.ChannelMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "channel_members" do
    belongs_to :channel, EngHub.Communities.Channel
    belongs_to :user, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  def changeset(channel_member, attrs) do
    channel_member
    |> cast(attrs, [:channel_id, :user_id])
    |> validate_required([:channel_id, :user_id])
    |> unique_constraint([:channel_id, :user_id])
  end
end
