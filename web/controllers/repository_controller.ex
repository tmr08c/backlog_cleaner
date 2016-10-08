defmodule BacklogCleaner.RepositoryController do
  use BacklogCleaner.Web, :controller

  def index(conn, params) do
    access_token = conn
    |> get_session(:access_token)

    repos = Tentacat.Client.new(%{access_token: access_token})
    |> Tentacat.Repositories.list_mine

    conn
    |> assign(:repos, repos)
    |> render("index.html")
  end
end
