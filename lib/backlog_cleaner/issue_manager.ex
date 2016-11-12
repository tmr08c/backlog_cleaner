defmodule BacklogCleaner.IssueManager do
  alias BacklogCleaner.AuditManager
  alias Tentacat.Issues

  @closed_state "closed"

  def close(tentacat_client, user, repo_owner, repo_name, issue_number) do
    with {:ok, _audit} <- AuditManager.create_close(user, repo_owner, repo_name, issue_number),
         {:ok, _issue} <- close_issue(tentacat_client, repo_owner, repo_name, issue_number),
         {201, _comment} <- create_comment(tentacat_client, repo_owner, repo_name, issue_number, close_comment_body(user)),
      do: {:ok}
  end

  def keep(tentacat_client, user, repo_owner, repo_name, issue_number) do
    with {:ok, _audit} <- AuditManager.create_keep(user, repo_owner, repo_name, issue_number),
         {201, _comment} <- create_comment(tentacat_client, repo_owner, repo_name, issue_number, keep_comment_body(user)),
    do: {:ok}
  end

  defp close_issue(tentacat_client, repo_owner, repo_name, issue_number) do
    issue = Issues.update(
      repo_owner,
      repo_name,
      issue_number,
      [state: @closed_state],
      tentacat_client
    )

    case issue do
      %{"state" => @closed_state} -> {:ok, issue}
      _ -> {:error, "Failed to close issue"}
    end
  end

  defp create_comment(tentacat_client, repo_owner, repo_name, issue_number, comment_body) do
    Issues.Comments.create(
      repo_owner,
      repo_name,
      issue_number,
      %{ "body" => comment_body },
      tentacat_client
    )
  end

  defp close_comment_body(user) do
       "@#{user.username} detemined this issue was stale and closed it using Backlog Cleaner" 
  end

  defp keep_comment_body(user) do
    "@#{user.username} detemined this issue is still valid using Backlog Cleaner" 
  end
end
