defmodule EngHub.Vault.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :storage_path, :string
    field :mime_type, :string
    field :size, :integer
    field :project_id, :id
    belongs_to :server, EngHub.Communities.Server, type: Ecto.ULID
    belongs_to :channel, EngHub.Communities.Channel, type: Ecto.ULID
    field :uploader_id, Ecto.ULID

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
      :channel_id
    ])
    |> validate_required([:filename, :storage_path, :mime_type, :size, :uploader_id])
  end
end
