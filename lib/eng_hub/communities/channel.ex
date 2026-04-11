defmodule EngHub.Communities.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "channels" do
    field :name, :string

    field :type, Ecto.Enum,
      values: [:general_chat, :project, :posts, :threads, :files, :hackathon],
      default: :general_chat

    field :position, :integer, default: 0

    belongs_to :server, EngHub.Communities.Server
    belongs_to :category, EngHub.Communities.Category

    # Existing compatibility (if needed)
    belongs_to :project_resource, EngHub.Projects.Project, foreign_key: :project_id

    has_many :messages, EngHub.Messaging.Message

    timestamps(type: :utc_datetime)
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :type, :position, :server_id, :category_id, :project_id])
    |> validate_required([:name, :type, :server_id])
  end
end
