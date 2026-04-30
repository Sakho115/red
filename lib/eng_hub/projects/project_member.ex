defmodule EngHub.Projects.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_roles ~w(viewer editor admin owner)

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "project_members" do
    field :role, :string, default: "viewer"
    belongs_to :project, EngHub.Projects.Project
    belongs_to :user, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project_member, attrs) do
    project_member
    |> cast(attrs, [:role, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
    |> validate_inclusion(:role, @valid_roles)
    |> unique_constraint([:project_id, :user_id],
      message: "user is already a member of this project"
    )
  end
end
