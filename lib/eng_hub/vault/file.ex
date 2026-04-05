defmodule EngHub.Vault.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :storage_path, :string
    field :mime_type, :string
    field :size, :integer
    field :project_id, :id
    field :uploader_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :storage_path, :mime_type, :size])
    |> validate_required([:filename, :storage_path, :mime_type, :size])
  end
end
