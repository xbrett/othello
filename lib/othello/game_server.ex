defmodule Othello.GameServer do
  use GenServer
  alias Othello.Game

  def reg(name) do
    {:via, Registry, {Othello.GameReg, name}}
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def view(game, user) do
    GenServer.call(__MODULE__, {:view, game, user})
  end
  def click(game, user, id) do
    GenServer.call(reg(game), {:click, game, user, id})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:view, game, user}, _from, state) do
    gg = Map.get(state, game, Game.new)
    gg = Game.addUser(gg, user)
    IO.puts("ADDED USER")
    {:reply, Game.client_view(gg), Map.put(state, game, gg)}
  end

  def handle_call({:click, game, user, id}, _from, state) do
    gg = Map.get(state, game, Game.new)
    |> Game.handleClick(user, id)
    {:reply, Game.client_view(gg), Map.put(state, game, gg)}
  end
end
