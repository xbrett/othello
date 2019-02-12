defmodule Othello.BackupAgent do
  use Agent

  # SOURCE: The following code is based on Nat's lecture notes
  # https://www.khoury.northeastern.edu/~ntuck/courses/2019/01/cs4550/notes/08-server-state/notes.html

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, val) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, val)
    end
  end

  def get(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

end
