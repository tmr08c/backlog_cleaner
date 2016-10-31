defmodule BacklogCleaner.RepositoryController do
  use BacklogCleaner.Web, :controller

  def index(conn, params) do
    repos = Tentacat.Client.new(%{access_token: conn.assigns.access_token})
    |> Tentacat.Repositories.list_mine

    conn
    |> assign(:repos, repos)
    |> render("index.html")
  end
end
