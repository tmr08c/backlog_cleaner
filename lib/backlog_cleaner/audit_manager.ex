defmodule BacklogCleaner.AuditManager do
  alias BacklogCleaner.Audit
  alias BacklogCleaner.Repo

  def create_keep(user, owner, repo, number) do
   create(Audit.keep_action, user, owner, repo, number) 
  end

  def create_close(user, owner, repo, number) do
    create(Audit.close_action, user, owner, repo, number)
  end

  defp create(action, user, owner, repo, number) do
    Audit.changeset(
      %Audit{},
      %{
        user_id: user.id,
        repo_owner: owner,
        repo_name: repo,
        issue_number: number,
        action: action
      }
    )
    |> Repo.insert
  end
end
