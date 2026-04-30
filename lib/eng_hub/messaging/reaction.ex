defmodule EngHub.Messaging.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "reactions" do
    field :emoji, :string

    belongs_to :message, EngHub.Messaging.Message
    belongs_to :user, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:emoji, :message_id, :user_id])
    |> validate_required([:emoji, :message_id, :user_id])
    |> unique_constraint([:message_id, :user_id, :emoji])
  end
end
