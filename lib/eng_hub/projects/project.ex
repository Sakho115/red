defmodule EngHub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :owner_id, Ecto.ULID
    belongs_to :server, EngHub.Communities.Server, type: Ecto.ULID

    has_many :channels, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :server_id])
    |> validate_required([:name, :description])
  end
end
