defmodule Othello.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {Othello.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Othello.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Othello.BackupAgent.get(name) || Othello.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def join(name, player) do
    GenServer.call(reg(name), {:join, name, player})
  end

  def click(name, tile) do
    GenServer.call(reg(name), {:guess, name, tile})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:join, name, player}, _from, game) do
    with {:ok, game} <- Othello.Game.addUser(game, player) do
      Othello.BackupAgent.put(name, game)
      {:reply, {:ok, game}, game}
    else
      {:error, msg} -> {:reply, {:error, msg}, game}
      _ -> {:reply, {:error, "unknown error"}, game}
    end
  end

  def handle_call({:click, name, tile}, _from, game) do
    with {:ok, game} <- Othello.Game.handleClick(game, tile) do
      Othello.BackupAgent.put(name, game)
      {:reply, {:ok, game}, game}
    else
      {:error, msg} -> {:reply, {:error, msg}, game}
      _ -> {:reply, {:error, "unknown error"}, game}
    end
  end
end
