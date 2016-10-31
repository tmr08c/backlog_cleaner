defmodule BacklogCleaner.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :name, :string
      add :avatar_url, :string

      timestamps()
    end

  end
end
