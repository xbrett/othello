defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.GameServer

  def join("game:" <> game, _payload, socket) do
    socket = assign(socket, :game, game)
    view = GameServer.view(game, socket.assigns[:user])
    {:ok, %{"join" => game, "game" => view}, socket}
  end

  def handle_in("click", %{"id" => id}, socket) do
    view = GameServer.click(socket.assigns[:name], socket.assigns[:user], id)
    push_update! view, socket
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_out("update", game, socket) do
    IO.inspect("Broadcasting update to #{socket.assigns[:user]}")
    push socket, "update", %{ "game" => game }
    {:noreply, socket}
  end

  defp push_update!(view, socket) do
    broadcast!(socket, "update", view)
  end

end
