defmodule BacklogCleaner.PageController do
  use BacklogCleaner.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      conn |> redirect(to: repository_path(conn, :index))
    else
      render conn, "index.html"
    end
  end
end
