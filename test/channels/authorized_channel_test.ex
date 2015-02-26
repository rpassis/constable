defmodule ConstableApi.AuthorizedChannelTest do
  use ConstableApi.TestWithEcto, async: false
  import ChannelTestHelper
  alias ConstableApi.Repo
  alias ConstableApi.Channel

  defmodule FakeChannel do
    use ConstableApi.AuthorizedChannel
  end

  alias FakeChannel, as: Channel

  test "authorize_socket returns authorized socket when token matches a user" do
    user = Forge.saved_user(Repo)
    socket = socket_with_topic

    {status, socket} = Channel.authorize_socket(socket, user.token)

    assert status == :ok
    assert socket == socket
  end

  test "authorize_socket assigns user_id when the auth token matches a user" do
    user = Forge.saved_user(Repo)
    socket = socket_with_topic

    {_status, socket} = Channel.authorize_socket(socket, user.token)

    assert socket.assigns[:current_user_id] == user.id
  end

  test "authorize_socket returns error when joining with an incorrect token" do
    Forge.saved_user(Repo)
    bad_token = "abc"
    socket = socket_with_topic

    {status, message, socket} =
      Channel.authorize_socket(socket, bad_token)

    assert status == :error
    assert message == :unauthorized
    assert socket == socket
  end

  test "current_user_id returns the user id stored in the socket" do
    user_id = 1
    socket = socket_with_topic |> assign_current_user(user_id)

    current_user_id = Channel.current_user_id(socket)

    assert current_user_id == user_id
  end
end