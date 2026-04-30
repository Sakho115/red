defmodule EngHub.Timeline.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "activities" do
    field :action_type, :string
    field :metadata, :map, default: %{}

    belongs_to :user, EngHub.Identity.User
    belongs_to :server, EngHub.Communities.Server
    belongs_to :project, EngHub.Projects.Project, type: Ecto.ULID

    timestamps(type: :utc_datetime)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:user_id, :server_id, :project_id, :action_type, :metadata])
    |> validate_required([:user_id, :action_type])
  end
end
