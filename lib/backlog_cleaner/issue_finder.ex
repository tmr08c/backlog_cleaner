defmodule BacklogCleaner.IssueFinder do
  alias Tentacat.Issues
  alias BacklogCleaner.Audit
  alias BacklogCleaner.Repo

  @doc """
  Given a repository owner and name returns a random open issue number.

  If `include_audited` is `true` it will look at all open issues in the repo.
  If `include_audited` is `false` it will ignore issues that have we have `Audit` records stored for. 
  """
  def random_issue_number_for(tentacat_client, owner, repo, include_audited \\ false) do
    open_issue_numbers =
      open_issues_for(owner, repo, tentacat_client)
      |> Enum.map(fn (issue) -> Map.get(issue, "number") end)

    if include_audited do
      open_issue_numbers
    else
      open_issue_numbers -- managed_issue_numbers_for(owner, repo)
    end
    |> random_issue
  end

  defp random_issue([]), do: {:error, :no_issues}
  defp random_issue(issues), do: {:ok, Enum.random(issues)}

  defp open_issues_for(owner, repo, tentacat_client) do
    Issues.list(owner, repo, tentacat_client)
  end

  defp managed_issue_numbers_for(owner, repo) do
    Audit
    |> Audit.for_repo(owner, repo)
    |> Audit.audited_issues
    |> Audit.issues_to_keep
    |> Repo.all
  end
end
