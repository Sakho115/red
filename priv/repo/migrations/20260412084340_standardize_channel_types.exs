defmodule EngHub.Repo.Migrations.StandardizeChannelTypes do
  use Ecto.Migration

  def up do
    execute "UPDATE channels SET type = 'hackathons' WHERE type = 'hackathon'"
    execute "UPDATE channels SET type = 'general_chat' WHERE type = 'chat'"
    execute "UPDATE channels SET type = 'general_chat' WHERE type = 'general'"
  end

  def down do
    # Partial rollback if needed, but since we are standardizing, 
    # rolling back might not be perfectly reversible for 'chat' -> 'general_chat'
    execute "UPDATE channels SET type = 'hackathon' WHERE type = 'hackathons'"
  end
end
