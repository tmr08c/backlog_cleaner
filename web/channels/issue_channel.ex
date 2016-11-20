defmodule BacklogCleaner.IssueChannel do
  use BacklogCleaner.Web, :channel

  alias BacklogCleaner.IssueManager
  alias BacklogCleaner.User

  def join("issues:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("issues:close", %{"owner" => owner, "repo" => repo, "issueNumber" => issue_number}, socket) do
    user = User.get(socket.assigns.user_id) |> BacklogCleaner.Repo.one
    access_token = socket.assigns.access_token

    case IssueManager.close(access_token, user, owner, repo, issue_number) do
      {:ok} ->
        # may want to instead `broadcast` so
        # all users looking at the same repo will
        # be updated 
        {:reply, :ok, socket}
      error ->
        {:reply, {:eror, error}, socket}
    end
  end

  def handle_in("issues:keep", %{"owner" => owner, "repo" => repo, "issueNumber" => issue_number}, socket) do
    user = User.get(socket.assigns.user_id) |> BacklogCleaner.Repo.one
    access_token = socket.assigns.access_token

    case IssueManager.keep(access_token, user, owner, repo, issue_number) do
      {:ok} ->
        # may want to instead `broadcast` so
        # all users looking at the same repo will
        # be updated 
        {:reply, :ok, socket}
      error ->
        {:reply, {:eror, error}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
