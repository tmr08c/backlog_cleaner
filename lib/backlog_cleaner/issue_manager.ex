defmodule BacklogCleaner.IssueManager do
  alias BacklogCleaner.Audit
  alias BacklogCleaner.Repo
  alias Tentacat.Issues

  def close(tentacat_client, user, repo_owner, repo_name, issue_number) do
    create_close_audit(user, repo_owner, repo_name, issue_number) &&
    close_issue(tentacat_client, repo_owner, repo_name, issue_number) &&
    create_close_comment(tentacat_client, repo_owner, repo_name, issue_number)
  end

  def keep do
  end

  defp create_close_audit(user, repo_owner, repo_name, issue_number) do
    changeset = Audit.close_changeset(user, repo_owner, repo_name, issue_number)

    case Repo.insert(changeset) do
      {:ok, _audit} ->
        true
      {:error, _changeset} ->
        false
    end
  end

  defp close_issue(tentacat_client, repo_owner, repo_name, issue_number) do
    Issues.update(repo_owner, repo_name, issue_number, [state: "closed"], tentacat_client)

    true
  end

  defp create_close_comment(tentacat_client, repo_owner, repo_name, issue_number) do
    Issues.Comments.create(
      repo_owner,
      repo_name,
      issue_number,
      %{ "body" => "It was determined that this issue was stale and has been closed via Backlog Cleaner"},
      tentacat_client
    )

    true
  end
end
