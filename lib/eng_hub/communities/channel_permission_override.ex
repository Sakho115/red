defmodule EngHub.Communities.ChannelPermissionOverride do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "channel_overrides" do
    field :type, Ecto.Enum, values: [:role, :member]
    field :target_id, Ecto.ULID
    field :allow, :integer, default: 0
    field :deny, :integer, default: 0

    belongs_to :channel, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  def changeset(override, attrs) do
    override
    |> cast(attrs, [:type, :target_id, :allow, :deny, :channel_id])
    |> validate_required([:type, :target_id, :channel_id])
  end
end
