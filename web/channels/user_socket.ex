defmodule BacklogCleaner.UserSocket do
  use Phoenix.Socket

  @max_age 1209600

  ## Channels
  # channel "room:*", BacklogCleaner.RoomChannel
  channel "issues:*", BacklogCleaner.IssueChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"userIdToken" => user_id_token, "accessTokenToken" => access_token_token}, socket) do
    with {:ok, user_id} <- verify_user_id(socket, user_id_token),
         {:ok, access_token} <- verify_access_token(socket, access_token_token),
     do: {:ok,
           socket
           |> assign(:user_id, user_id)
           |> assign(:access_token, access_token)
         }
  end

  defp verify_user_id(socket, user_id_token) do
    Phoenix.Token.verify(socket, "user socket", user_id_token, max_age: @max_age)
  end

  defp verify_access_token(socket, access_token_token) do
    Phoenix.Token.verify(socket, "user socket", access_token_token, max_age: @max_age)
  end

# Socket id's are topics that allow you to identify all sockets for a given user:
#
#     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
#
# Would allow you to broadcast a "disconnect" event and terminate
# all active sockets and channels for a given user:
#
#     BacklogCleaner.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
#
# Returning `nil` makes this socket anonymous.
def id(_socket), do: nil
end
