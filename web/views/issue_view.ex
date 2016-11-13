defmodule BacklogCleaner.IssueView do
  use BacklogCleaner.Web, :view

  def issue_body(issue) do
    Map.get(issue, "body")
    |> Earmark.to_html(%Earmark.Options{breaks: true})
    |> HtmlSanitizeEx.basic_html
  end

  def last_updated(issue) do
    with {:ok, timestamp} <-
      issue
      |> Map.get("updated_at")
      |> Timex.parse("{ISO:Extended:Z}"),
    do: Timex.from_now(timestamp)
  end
end
