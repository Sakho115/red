defmodule EngHub.Messaging.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :name, :string
    belongs_to :project, EngHub.Projects.Project
    has_many :messages, EngHub.Messaging.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :project_id])
    |> validate_required([:name, :project_id])
  end
end
