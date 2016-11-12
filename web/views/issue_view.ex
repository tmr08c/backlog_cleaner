defmodule BacklogCleaner.IssueView do
  use BacklogCleaner.Web, :view

  def issue_body(issue) do
    Map.get(issue, "body")
    |> Earmark.to_html(%Earmark.Options{breaks: true})
    |> HtmlSanitizeEx.basic_html
  end
end
