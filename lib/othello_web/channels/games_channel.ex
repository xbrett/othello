defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  #alias Othello.GameServer
  alias Othello.BackupAgent
  alias Othello.Game

  # def join("game:" <> game, _payload, socket) do
  #   socket = assign(socket, :game, game)
  #   IO.inspect(game)
  #   lala = socket.assigns[:user]
  #   IO.inspect(lala)
  #   view = GameServer.view(game, lala)
  #   #push_update! view, socket
  #   {:ok, %{"join" => game, "game" => view}, socket}
  # end

  # def handle_in("click", %{"id" => id}, socket) do
  #   view = GameServer.click(socket.assigns[:game], socket.assigns[:user], id)
  #   push_update! view, socket
  #   {:reply, {:ok, %{ "game" => view}}, socket}
  # end

  # def handle_out("update", game, socket) do
  #   IO.inspect("Broadcasting update to #{socket.assigns[:user]}")
  #   push socket, "update", %{ "game" => game }
  #   {:noreply, socket}
  # end

  # defp push_update!(view, socket) do
  #   broadcast!(socket, "update", view)
  # end

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
    IO.inspect(view)
    view = Game.handleClick(view, socket.assigns[:user], id)
    #IO.inspect(view)
    BackupAgent.put(socket.assigns[:game], view)

    OthelloWeb.Endpoint.broadcast("game:#{game}", "update", %{"game" => view})
    # push_update view, socket
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_out("update", game, socket) do
    IO.inspect("Broadcasting update to #{socket.assigns[:user]}")
    push socket, "update", %{ "game" => game }
    {:noreply, socket}
  end

  defp push_update(view, socket) do
    broadcast!(socket, "update", view)
  end

end
