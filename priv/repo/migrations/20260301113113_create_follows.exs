defmodule EngHub.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :follower_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :following_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:follows, [:follower_id])
    create index(:follows, [:following_id])

    create unique_index(:follows, [:follower_id, :following_id],
             name: :follows_follower_following_index
           )
  end
end
