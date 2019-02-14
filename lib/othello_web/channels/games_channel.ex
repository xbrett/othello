defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.BackupAgent

  def join("game:" <> name, %{}, socket) do
    game = BackupAgent.get(name) || Game.new()
    socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
    BackupAgent.put(name, game)
    {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
  end

  def handle_in("new", _payload, socket) do
    game = Game.new()
    socket = assign(socket, :game, game)
    BackupAgent.put(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

  def handle_in("click", %{"tile" => tile}, socket) do
    game = Game.handle_click(socket.assigns[:game], Util.to_atoms(tile));
    socket = assign(socket, :game, game)
    BackupAgent.put(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

end
