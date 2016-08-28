defmodule BacklogCleaner.PageController do
  use BacklogCleaner.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
