defmodule EngHub.Repo.Migrations.AddBannerUrlToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :banner_url, :string
    end
  end
end
