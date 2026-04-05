defmodule EngHub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :owner_id, :id
    
    has_many :channels, EngHub.Messaging.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
