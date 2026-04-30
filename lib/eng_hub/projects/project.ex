defmodule EngHub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "projects" do
    field :name, :string
    field :description, :string
    field :owner_id, Ecto.ULID
    field :metadata, :map, default: %{}
    belongs_to :server, EngHub.Communities.Server

    has_many :channels, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :server_id, :metadata])
    |> validate_required([:name, :description])
  end
end
