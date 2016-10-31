defmodule BacklogCleaner.Router do
  use BacklogCleaner.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BacklogCleaner.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]

    post "/webhook", WebHookController, :index
  end

  scope "/", BacklogCleaner do
    pipe_through :browser

    resources "/session", SessionController, only: [:new, :delete], singleton: true
  end

  scope "/", BacklogCleaner do
    pipe_through [:browser, BacklogCleaner.Plugs.Auth] # Use the default browser stack

    get "/", RepositoryController, :index
    get "/repositories", RepositoryController, :index
    get "/repository/:owner/:repo/issues", IssueController, :index
    get "/repository/:owner/:repo/issue/:number", IssueController, :show
    delete "/repository/:owner/:repo/issue/:number", IssueController, :delete
  end

  scope "/auth", BacklogCleaner do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", BacklogCleaner do
  #   pipe_through :api
  # end
end
