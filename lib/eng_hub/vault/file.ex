defmodule EngHub.Vault.File do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "files" do
    field :filename, :string
    field :storage_path, :string
    field :mime_type, :string
    field :size, :integer
    belongs_to :project, EngHub.Projects.Project
    belongs_to :server, EngHub.Communities.Server
    belongs_to :channel, EngHub.Communities.Channel
    belongs_to :uploader, EngHub.Identity.User
    field :cid, :string
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [
      :filename,
      :storage_path,
      :mime_type,
      :size,
      :project_id,
      :uploader_id,
      :server_id,
      :channel_id,
      :cid,
      :metadata
    ])
    |> validate_required([:filename, :storage_path, :mime_type, :size, :uploader_id])
  end
end
