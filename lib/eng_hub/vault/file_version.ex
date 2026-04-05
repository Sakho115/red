defmodule EngHub.Vault.FileVersion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "file_versions" do
    field :version_number, :integer
    field :storage_path, :string
    field :file_id, :id
    field :created_by_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file_version, attrs) do
    file_version
    |> cast(attrs, [:version_number, :storage_path])
    |> validate_required([:version_number, :storage_path])
  end
end
