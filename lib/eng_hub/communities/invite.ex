defmodule EngHub.Communities.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "invites" do
    field :code, :string
    field :max_uses, :integer
    field :uses, :integer, default: 0
    field :expires_at, :utc_datetime

    belongs_to :server, EngHub.Communities.Server
    belongs_to :inviter, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:server_id, :inviter_id, :code, :max_uses, :uses, :expires_at])
    |> validate_required([:server_id, :inviter_id, :code])
    |> unique_constraint(:code)
  end
end
