# 
# This is based on the example found:
# https://github.com/scrogson/oauth2_example/blob/master/web/controllers/auth_controller.ex
#

defmodule BacklogCleaner.AuthController do
  use BacklogCleaner.Web, :controller
  alias BacklogCleaner.User

  @doc """
  This action is reached via `/auth/:provider` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def delete(conn, _params) do
    conn
    |> BacklogCleaner.Plugs.Auth.logout
  end

  @doc """
  This action is reached via `/auth/:provider/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(conn, %{"provider" => provider, "code" => code}) do
    # Exchange an auth code for an access token
    client = get_token!(provider, code)

    # Request the user's data with the access token
    user = get_user!(provider, client)

    # Store The user in the session under `:current_user` and redirect to /.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    if user do
      conn |> BacklogCleaner.Plugs.Auth.login(user, client.token.access_token)
    else
      conn
      |> put_flash(:error, "Error signing in")
      |> redirect(to: "/")
    end
  end

  defp authorize_url!("github"), do: GitHub.authorize_url!
  defp authorize_url!(_), do: raise "No matching provider available"

  defp get_token!("github", code),   do: GitHub.get_token!(code: code)
  defp get_token!(_, _), do: raise "No matching provider available"

  defp get_user!("github", client) do
    %{body: user} = OAuth2.Client.get!(client, "/user")

    find_or_insert_user(
      user["email"],
      user["login"],
      user["name"],
      user["avatar_url"]
    )
  end

  defp find_or_insert_user(email, login, name, avatar_url) do
    Repo.one(User.with_email(email)) ||
    insert_new_user(email, login, name, avatar_url)
  end

  defp insert_new_user(email, login, name, avatar_url) do
    changeset =
      User.changeset(
       %User{},
        %{email: email, username: login, name: name, avatar_url: avatar_url}
      )

    case Repo.insert(changeset) do
      {:ok, user} ->
        user
      {:error, _changeset} ->
        nil
    end
  end
end
