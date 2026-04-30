defmodule EngHub.Vault.FileVersion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "file_versions" do
    field :version_number, :integer
    field :storage_path, :string
    belongs_to :file, EngHub.Vault.File
    belongs_to :created_by, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file_version, attrs) do
    file_version
    |> cast(attrs, [:version_number, :storage_path])
    |> validate_required([:version_number, :storage_path])
  end
end
