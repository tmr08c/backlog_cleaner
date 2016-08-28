defmodule Github.Webhook do
  @client  Tentacat.Client.new(%{user: "tmr08c", password: "f@11ISh3r3"})

  def create do
    Tentacat.Hooks.create(
      "tmr08c",
      "tmr08c.github.io",
      %{
        "name" => "web",
        "active" => true,
        "events" => ["*"],
        "config" => %{
          "url" => "http://990e56fc.ngrok.io/webhook",
          "content_type" => "json"
        }
      },
      @client
    )
  end

  def update do
    id = "9677617"
    Tentacat.Hooks.update(
      "tmr08c",
      "tmr08c.github.io",
      id,
      %{
        "config" => %{
          "url" => "http://990e56fc.ngrok.io/webhook"
        }
      },
      @client
    )
  end
end
