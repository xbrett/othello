defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameServer

  def join("game:" <> name, %{"player" => player}, socket) do
    GameServer.reg(name)
    GameServer.start(name)
    reply = GameServer.join(name, player)

    socket = socket
    |> assign(:name, name)
    |> assign(:user, user)

    case reply do
      {:ok, game} -> {:ok, %{game: Game.client_view(game, player)}, socket}
      {:error, msg} -> {:error, %{msg: msg}}
      _ -> {:error, %{msg: "unknown error"}}
    end
  end

  def handle_in("click", %{"tile" => tile}, socket) do
    reply = GameServer.click(socket.assigns[:name], tile)
    case reply do
      {:ok, game} -> broadcast(socket, "playing", %{game: Game.client_view(game)})
                    {:noreply, socket}
      {:error, msg} -> {:reply, {:error, %{msg: msg}}, socket}
      _ -> {:reply, {:error, %{msg: "unknown error"}}, socket}
    end
  end

end
