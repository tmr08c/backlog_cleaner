defmodule BacklogCleaner.IssueController do
  use BacklogCleaner.Web, :controller

  alias BacklogCleaner.AuditFinder
  alias BacklogCleaner.IssueFinder
  alias BacklogCleaner.IssueManager

  plug :check_all

  # Long term we may want to store issues in an ETS table
  # as a form of local caching.
  #
  # We would need to be sure to rectify the cache against changes
  # probably via a webhook

  def index(conn, %{ "owner" => owner, "repo" => repo } = params) do
    issues =
      conn
      |> tentacat_client
      |> IssueFinder.issues_for(owner, repo, conn.assigns.all)

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issues, issues)
    |> render("index.html")
  end

  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => "random" } = params) do
    case conn
    |> tentacat_client
    |> IssueFinder.random_issue_number_for(owner, repo, conn.assigns.all) do
      {:error, _} -> conn |> redirect(to: issue_path(conn, :index, owner, repo))
      {:ok, issue} -> conn |> redirect(to: issue_path(conn, :show, owner, repo, issue))
    end
  end

  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    issue = 
      conn
      |> tentacat_client
      |> IssueFinder.issue_for(owner, repo, number)

    # check for audit for this isse
    audit = AuditFinder.most_recent_for(owner, repo, number)

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issue, issue)
    |> assign(:audit, audit)
    |> render("show.html")
  end

  def delete(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    client = conn |> tentacat_client

    case IssueManager.close(client, conn.assigns.current_user, owner, repo, number) do
      {:ok} ->
        conn
        |> put_flash(:info, "Closing issue")
        |> redirect(to: issue_path(conn, :show, owner, repo, "random"))
      _error ->
        conn
        |> put_flash(:error, "Error closing issue. Please try again.")
        |> redirect(to: issue_path(conn, :show, owner, repo, number))
    end
  end

  def keep(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    client = conn |> tentacat_client

    case IssueManager.keep(client, conn.assigns.current_user, owner, repo, number) do
      {:ok} ->
        conn
        |> put_flash(:info, "Flagged issue as keep")
        |> redirect(to: issue_path(conn, :show, owner, repo, "random"))
      _error ->
        conn
        |> put_flash(:error, "Error marking issue as to keep")
        |> redirect(to: issue_path(conn, :show, owner, repo, number))
    end
  end

  @doc """
  Plug used to track whether or not to include issues that have
  already been audited/flagged to keep open.
  """
  defp check_all(conn, _opts) do
    case conn.query_params["all"] do
      "true" ->
        conn
        |> put_session(:all, true)
        |> assign(:all, true)
      "false" ->
        conn
        |> put_session(:all, false)
        |> assign(:all, false)
      _ ->
        check_all = get_session(conn, :all)
        conn
        |> assign(:all, check_all)
    end
  end

  defp tentacat_client(conn) do
    Tentacat.Client.new(%{access_token: conn.assigns.access_token})
  end
end

