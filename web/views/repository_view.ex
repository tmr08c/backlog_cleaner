defmodule BacklogCleaner.RepositoryView do
  use BacklogCleaner.Web, :view

  def full_name(repo), do: repo |> Map.get("full_name")

  def name(repo), do: repo |> Map.get("name")

  def owner(repo), do: repo |> Map.get("owner") |> Map.get("login")

  def issue_count(repo), do: repo |> Map.get("open_issues")
end
