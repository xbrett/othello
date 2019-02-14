defmodule Othello.Game do
	"""
	To keep truck of players turns, we store "black" or "white" in turn, 
	black --> player1's turn  --> black pieces
	white --> player2's turn  --> white pieces
	"""


	def new do
		state = 
		%{
			board: [],
			turn: "black",
			....
			player1: "",
			player2: "",
		}

		@start_white_piece1_id = 27
		@start_black_piece1_id = 28
		@start_white_piece2_id = 35
		@start_blakc_piece2_id = 36

		builtBoard = Enum.map(0..63, fn x -> %{id: x, row: div(x, 8), col: rem(x, 8), empty: true, color: nil} end)

		sp1 = builtBoard
			|> Enum.at(@start_white_piece1_id)  # starting white piece 1
			|> Map.put(:empty, false)
			|> Map.put(:color, "white")

		sp2 = builtBoard
			|> Enum.at(@start_black_piece1_id)  # starting black piece 1
			|> Map.put(:empty, false)
			|> Map.put(:color, "black")

		sp3 = builtBoard
			|> Enum.at(@start_white_piece2_id)  # starting white piece 2
			|> Map.put(:empty, false)
			|> Map.put(:color, "white")

		sp4 = builtBoard
			|> Enum.at(@start_black_piece2_id)  # starting black piece 2
			|> Map.put(:empty, false)
			|> Map.put(:color, "black")

		builtBoard = builtBoard
			|> List.replace_at(@start_white_piece1_id, sp1)
			|> List.replace_at(@start_black_piece1_id, sp2)
			|> List.replace_at(@start_white_piece2_id, sp3)
			|> List.replace_at(@start_black_piece2_id, sp4)

		Map.put(state, :board, builtBoard)
	end

	
	def client_view(game) do
		%{
			board: game.board,
			turn: game.turn,
			....
			player1: game.player1,
			player2: game.player2
		}
	end

	def reset(game) do
		new()
	end

	def addUser(game, userName) do
		# If there is no player1, add player1
		if (game.player1 == "") do
			game
				|> Map.put(:player1, userName)

		else  # There is already player1, so we are adding player2
			# handle duplicate name needed???
			if (game.player2 == "") do
				game
					|> Map.put(:player2, userName)

			else	# There are two players in the game already
				## TODO ??? ##
			end
		end
	end	

	def handleClick(game, id) do
		# Only allow clicking empty cells
		if (Enum.at(game.board, id).empty) do
			
			# TODO

		else
			IO.puts("BAD click")			
		end
	end

	# Given the cell id, ensures that the move is valid
	# board (array), id --> boolean
	def validMove(game, id) do
		# Based on clicked id, find the row and column
		rowC = Enum.at(game.board, id).row
		colC = Enum.at(game.board, id).col
		playerTurn = game.turn

		ret = false;

		# check four directions for valid move (not empty and the color is opposite to this one)

		# Check left neighbor
		if (colC - 1 >= 0 && Enum.at(game.board, rcToId(row, colC - 1)).color != game.turn) do
			ret = ret || checkDirect(game, rowC, colC - 2, "left")
		end

		# Check right neighbor
		if (colC + 1 < 8 && Enum.at(game.board, rcToId(row, colC + 1)).color != game.turn) do
			ret = ret || checkDirect(game, rowC, colC + 2, "right")
		end

		# Check top neighbor
		if (rowC - 1 < 8 && Enum.at(game.board, rcToId(row - 1, colC)).color != game.turn) do
			ret = ret || checkDirect(game, rowC - 2, colC, "top")
		end

		# Check bottom neighbor
		if (rowC + 1 < 8 && Enum.at(game.board, rcToId(row + 1, colC)).color != game.turn) do
			ret = ret || checkDirect(game, rowC + 2, colC, "bottom")
		end

		# Can add if checks to stop whenever the first true (if any) is encountered as result of checkDirect
		ret
	end

	# Given row and column of the board, calculates and retrurns the corresponding id
	defp rcToId(row, column) do
		column + (row * 8)
	end

	# Case of getting out of bounds
	defp checkDirect(game, row, col) do
		false
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells to the left until finds the match, out of 
	# bounds or empty cell is encountered
	defp checkDirect(game, row, col, "left") do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
				false
			col >= 0 && col < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
					true
				else
					checkDirect(game, row, col - 1, "left")
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells to the right until finds the match, out of 
	# bounds or empty cell is encountered
	defp checkDirect(game, row, col, "right") do
		cond do 
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
				false
			col >= 0 && col < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
					true
				else
					checkDirect(game, row, col + 1, "right")
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells above until finds the match, out of bounds
	# or empty cell is encountered
	defp checkDirect(game, row, col, "top") do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
				false
			row >= 0 && row < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
					true
				else
					checkDirect(game, row - 1, col, "top")
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells below until finds the match, out of bounds
	# or empty cell is encountered
	defp checkDirect(game, row, col, "bottom") do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
				false
			row >= 0 && row < 8 ->	# valid row
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
					true
				else
					checkDirect(game, row + 1, col, "bottom")
				end
			true ->
				checkDirect(game, row, col)
		end
	end
end

