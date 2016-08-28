defmodule WebHookController do
  use BacklogCleaner.Web, :controller

  #
  # Process all webooks
  #
  # * Filter on repo
  def index(conn, %{"payload" => payload} = params) do
    {:ok, body} = JSON.decode(payload)

    IO.inspect(body)
    send_resp(conn, 200, "")
  end
end
