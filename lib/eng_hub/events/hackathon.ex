defmodule EngHub.Events.Hackathon do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hackathons" do
    field :title, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime

    field :project_id, :integer
    belongs_to :server, EngHub.Communities.Server, type: :binary_id
    belongs_to :channel, EngHub.Communities.Channel, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hackathon, attrs) do
    hackathon
    |> cast(attrs, [:title, :start_date, :end_date, :project_id, :server_id, :channel_id])
    |> validate_required([:title, :start_date, :end_date])
  end
end
