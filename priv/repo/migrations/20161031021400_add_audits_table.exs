defmodule BacklogCleaner.Repo.Migrations.AddAuditsTable do
  use Ecto.Migration

  def change do
    create table(:audits) do
      add :user_id, references(:users)
      add :repo_owner, :string
      add :repo_name, :string
      add :issue_number, :integer
      add :action, :string

      timestamps()
    end
  end
end
