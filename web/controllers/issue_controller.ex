defmodule BacklogCleaner.IssueController do
  use BacklogCleaner.Web, :controller

  # Long term we may want to store issues in an ETS table
  # as a form of local caching.
  #
  # We would need to be sure to rectify the cache against changes
  # probably via a webhook

  def index(conn, %{ "owner" => owner, "repo" => repo } = params) do
    access_token = conn |> get_session(:access_token)

    client = Tentacat.Client.new(%{access_token: access_token})
    issues = Tentacat.Issues.list(owner, repo, client)

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issues, issues)
    |> render("index.html")
  end


  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => "random" } = params) do
    access_token = conn |> get_session(:access_token)

    client = Tentacat.Client.new(%{access_token: access_token})
    issue = Tentacat.Issues.list(owner, repo, client) |> Enum.random

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issue, issue)
    |> render("show.html")
  end

  def show(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    access_token = conn |> get_session(:access_token)

    client = Tentacat.Client.new(%{access_token: access_token})
    issue = Tentacat.Issues.find(owner, repo, number, client)

    conn
    |> assign(:owner, owner)
    |> assign(:repo, repo)
    |> assign(:issue, issue)
    |> render("show.html")
  end

  def delete(conn, %{ "owner" => owner, "repo" => repo, "number" => number } = params) do
    access_token = conn |> get_session(:access_token)

    client = Tentacat.Client.new(%{access_token: access_token})

    Tentacat.Issues.Comments.create(
      owner,
      repo,
      number,
      %{ "body" => "It was determined that this issue was stale and has been closed via Backlog Cleaner"},
      client
    )
    Tentacat.Issues.update(
      owner,
      repo,
      number,
      [state: "closed"],
      client
    )

    conn
    |> redirect(to: issue_path(conn, :index, owner, repo))
  end
end
