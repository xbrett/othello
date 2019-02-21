defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameServer

  def join("game:" <> game, _payload, socket) do
    socket = assign(socket, :game, game)
    view = GameServer.view(game, socket.assigns[:user])
    {:ok, %{"join" => game, "game" => view}, socket}
  end

  def handle_in("click", %{"id" => id}, socket) do
    reply = GameServer.click(socket.assigns[:name], socket.assigns[:user], id)
    case reply do
      {:ok, game} -> broadcast(socket, "playing", %{game: Game.client_view(game)})
                    {:noreply, socket}
      {:error, msg} -> {:reply, {:error, %{msg: msg}}, socket}
      _ -> {:reply, {:error, %{msg: "unknown error"}}, socket}
    end
  end

end
