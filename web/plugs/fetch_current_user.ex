defmodule BacklogCleaner.Plugs.FetchCurrentUser do
  @moduledoc """
  This plug with assign `current_user` and `access_token` based
  session variables `user_id` and `access_token`.

  This plug should be used with all requests to set up current
  user information.
  """
  import Plug.Conn

  alias BacklogCleaner.Repo
  alias BacklogCleaner.User

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> set_current_user
    |> set_access_token
  end

  defp set_current_user(conn) do
    user_id = get_session(conn, :user_id)
    user = user_id && Repo.get(User, user_id)
    user_id_token = Phoenix.Token.sign(conn, "user socket", user_id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_id_token, user_id_token)
  end

  defp set_access_token(conn) do
    access_token = conn |> get_session(:access_token)
    access_token_token = Phoenix.Token.sign(conn, "user socket", access_token)

    conn
    |> assign(:access_token, access_token)
    |> assign(:access_token_token, access_token_token)
  end
end
