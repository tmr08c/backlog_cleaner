defmodule BacklogCleaner.AuditFinder do
  alias BacklogCleaner.Audit
  alias BacklogCleaner.Repo

  def most_recent_for(owner, repo, number) do
    Audit
    |> Audit.for_repo(owner, repo)
    |> Audit.for_issue(number)
    |> Audit.with_user
    |> Audit.most_recent
    |> Repo.one
  end
end
