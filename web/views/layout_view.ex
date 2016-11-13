defmodule BacklogCleaner.LayoutView do
  use BacklogCleaner.Web, :view

  def fa(name) do
    content_tag(:i, "", class: "fa fa-#{name}")
  end
end
