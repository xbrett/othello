defmodule Memory.Util do

  def to_atoms(str_map) do
    Map.new(str_map, fn {k, v} -> {String.to_atom(k), v} end)
  end

end
