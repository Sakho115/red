defmodule EngHub.Discussions.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "threads" do
    field :category, :string
    field :title, :string
    field :content, :string
    field :type, :string, default: "discussion"
    belongs_to :author, EngHub.Identity.User
    belongs_to :project, EngHub.Projects.Project
    belongs_to :server, EngHub.Communities.Server
    belongs_to :channel, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [
      :category,
      :title,
      :content,
      :project_id,
      :author_id,
      :server_id,
      :channel_id,
      :type
    ])
    |> validate_required([:category, :title, :content, :author_id])
  end
end
