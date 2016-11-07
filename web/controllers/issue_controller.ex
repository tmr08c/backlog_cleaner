defmodule BacklogCleaner.IssueController do
  use BacklogCleaner.Web, :controller

  alias BacklogCleaner.Audit
  alias BacklogCleaner.IssueManager

  # Long term we may want to store issues in an ETS table
  # as a form of local caching.
  #
  # We would need to be sure to rectify the cache against changes
  # probably via a webhook

  def index(conn, %{ "owner" => owner, "repo" => repo } = params) do
    access_token = conn.assigns.access_token
    client = Tentacat.Client.new(%{access_token: access_token})
    issues = Tentacat.Issues.list(owner, repo, client)

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issues, issues)
    |> render("index.html")
  end

  # Need to add handling for no issues
  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => "random" } = params) do
    issue =
      conn
      |> tentacat_client
      |> BacklogCleaner.IssueFinder.random_issue_number_for(owner, repo) 

    conn
    |> redirect(to: issue_path(conn, :show, owner, repo, issue))
  end

  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    issue = Tentacat.Issues.find(owner, repo, number, tentacat_client(conn))

    # check for audit for this isse
    audit = Audit
    |> Audit.for_repo(owner, repo)
    |> Audit.for_issue(number)
    |> Audit.with_user
    |> Audit.sorted
    |> Repo.one

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issue, issue)
    |> assign(:audit, audit)
    |> render("show.html")
  end

  def delete(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    client = conn |> tentacat_client

    if IssueManager.close(client, conn.assigns.current_user, owner, repo, number) do
      conn
      |> put_flash(:info, "Closing issue")
      |> redirect(to: issue_path(conn, :show, owner, repo, "random"))
    else
      conn
      |> put_flash(:error, "Error closing issue. Please try again.")
      |> redirect(to: issue_path(conn, :show, owner, repo, number))
    end
  end

  def keep(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    changeset = Audit.changeset(
      %Audit{},
      %{
        user_id: conn.assigns.current_user.id,
        repo_owner: owner,
        repo_name: repo,
        issue_number: number,
        action: "keep"
      }
    )
    case Repo.insert(changeset) do
      {:ok, audit} ->
        conn
        |> put_flash(:info, "Flagged issue as keep")
        |> redirect(to: issue_path(conn, :show, owner, repo, "random"))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error marking issue as to keep")
        |> redirect(to: issue_path(conn, :show, owner, repo, number))
    end
  end

  defp tentacat_client(conn) do
    Tentacat.Client.new(%{access_token: conn.assigns.access_token})
  end
end

