defmodule EngHub.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "messages" do
    field :content, :string
    belongs_to :user, EngHub.Identity.User, type: Ecto.ULID
    belongs_to :channel, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :channel_id])
    |> validate_required([:content, :user_id, :channel_id])
  end
end
