defmodule EngHub.Events.Hackathon do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "hackathons" do
    field :title, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime

    belongs_to :project, EngHub.Projects.Project
    belongs_to :server, EngHub.Communities.Server
    belongs_to :channel, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hackathon, attrs) do
    hackathon
    |> cast(attrs, [:title, :start_date, :end_date, :project_id, :server_id, :channel_id])
    |> validate_required([:title, :start_date, :end_date])
  end
end
