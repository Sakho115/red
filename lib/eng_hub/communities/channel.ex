defmodule EngHub.Communities.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "channels" do
    field :name, :string
    field :topic, :string

    field :type, Ecto.Enum,
      values: [:general_chat, :project, :posts, :threads, :files, :hackathons, :listings, :dm],
      default: :general_chat

    field :position, :integer, default: 0

    belongs_to :server, EngHub.Communities.Server
    belongs_to :category, EngHub.Communities.Category

    # Existing compatibility (if needed)
    belongs_to :project_resource, EngHub.Projects.Project, foreign_key: :project_id

    has_many :messages, EngHub.Messaging.Message
    has_many :memberships, EngHub.Communities.ChannelMember
    has_many :members, through: [:memberships, :user]

    timestamps(type: :utc_datetime)
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :type, :position, :server_id, :category_id, :project_id, :topic])
    |> validate_required([:type])
    |> validate_server_id_based_on_type()
  end

  defp validate_server_id_based_on_type(changeset) do
    case get_field(changeset, :type) do
      :dm -> changeset
      _ -> validate_required(changeset, [:name, :server_id])
    end
  end
end
