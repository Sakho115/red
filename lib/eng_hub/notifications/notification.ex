defmodule EngHub.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "notifications" do
    field :title, :string
    field :body, :string
    field :type, :string
    field :read_at, :utc_datetime
    field :metadata, :map, default: %{}

    belongs_to :user, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :title, :body, :type, :read_at, :metadata])
    |> validate_required([:user_id, :title, :type])
  end
end
