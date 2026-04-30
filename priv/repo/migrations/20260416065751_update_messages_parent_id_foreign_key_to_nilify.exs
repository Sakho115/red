defmodule EngHub.Repo.Migrations.UpdateMessagesParentIdForeignKeyToNilify do
  use Ecto.Migration

  def up do
    drop constraint(:messages, "messages_parent_id_fkey")

    alter table(:messages) do
      modify :parent_id, references(:messages, on_delete: :nilify_all, type: :binary_id)
    end
  end

  def down do
    drop constraint(:messages, "messages_parent_id_fkey")

    alter table(:messages) do
      modify :parent_id, references(:messages, on_delete: :nothing, type: :binary_id)
    end
  end
end
