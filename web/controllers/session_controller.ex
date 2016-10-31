defmodule BacklogCleaner.SessionController do
  use BacklogCleaner.Web, :controller

  def new(conn, _) do
    if current_user?(conn) && current_access_token?(conn) do
      IO.puts("session controller - have current user")
      conn
      |> redirect(to: repository_path(conn, :index))
    else
      IO.puts("session controller - no current user")
      render conn, "new.html"
    end
  end

  def delete(conn, _) do
    BacklogCleaner.Plugs.Auth.logout(conn)
  end

  defp current_user?(conn) do
    conn.assigns.current_user
  end

  defp current_access_token?(conn) do
    conn.assigns.access_token
  end
end
