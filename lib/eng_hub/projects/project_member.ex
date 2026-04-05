defmodule EngHub.Projects.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_members" do
    field :role, :string
    field :project_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project_member, attrs) do
    project_member
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
