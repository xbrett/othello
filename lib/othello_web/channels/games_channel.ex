defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.BackupAgent
  alias Othello.Game

  def join("game:" <> game, _payload, socket) do
    socket = assign(socket, :game, game)
    view = BackupAgent.get(game) || Game.new()
    user = socket.assigns[:user]
    view = Game.addUser(view, user)
    OthelloWeb.Endpoint.broadcast("game:#{game}", "update", %{"game" => view})
    BackupAgent.put(socket.assigns[:game], view)
    {:ok, %{"join" => game, "game" => view}, socket}
  end

  def handle_in("click", %{"id" => id}, socket) do
    game = socket.assigns[:game]
    view = BackupAgent.get(game)
    view = Game.handleClick(view, socket.assigns[:user], id)
    BackupAgent.put(game, view)
    OthelloWeb.Endpoint.broadcast("game:#{game}", "update", %{"game" => view})
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("restart", %{}, socket) do
    game = socket.assigns[:game]
    view = BackupAgent.get(game)
    view = Game.reset(view)
    BackupAgent.put(game, view)
    OthelloWeb.Endpoint.broadcast("game:#{game}", "update", %{"game" => view})
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_out("update", game, socket) do
    IO.inspect("Broadcasting update to #{socket.assigns[:user]}")
    push socket, "update", %{ "game" => game }
    {:noreply, socket}
  end

end
