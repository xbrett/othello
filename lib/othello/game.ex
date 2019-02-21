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
			player1: "",
			player2: "",
            status: ""
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
			player1: game.player1,
			player2: game.player2,
            status: game.status
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

			# else	# There are two players in the game already
				## TODO ??? ##
			end
		end
	end

	def handleClick(game, id) do
		# Only allow clicking empty cells

		if (Enum.at(game.board, id).empty) do
      thisTurn = game.turn
      nextTurn = ""
      if (game.turn == "black") do
        nextTurn = "white"
      else
        nextTurn = "black"
      end

      pcsToTurn = findPcsToFlip(game, id)
      # There is somehting to turn based on the valid move
      if (length(pcsToTurn != 0)) do
        newBoard = Enum.map(pcsToTurn, fn x ->
            Enum.at(game.board, x).color = game.turn
            end)
        game
        	|> Map.put(:board, newBoard)
      end

      if (noMove(game, nextTurn)) do
        if (noMove(game, thisTurn)) do
          # END GAME
          game
          	|> Map.put(:status, "finished")
        else
          # Keep  playing
          game
        end
      else
        game
      end
		else
			IO.puts("BAD click")
		end
	end

  def noMove(game, gTurn) do
    ret = true
    game
    	|> Map.put(:turn, gTurn)

    Enum.map(0..63, fn x ->
      if (Enum.at(game.board, x).empty) do
        if (length(findPcsToFlip(game, x)) > 0) do
          # There is a valid move for given player
          ret = false
        end
      end
    end)

    ret
  end

	# Given the cell id, finds the ids of pieces to flip
	# game, id --> list of pieces' id to turn
	def findPcsToFlip(game, id) do
		# Based on clicked id, find the row and column
		rowC = Enum.at(game.board, id).row
		colC = Enum.at(game.board, id).col
		playerTurn = game.turn

    pcsToTurn = []  # Pieces to turn

		# check four directions for pieces to flip (not empty and the color is opposite to this one)

		# Check left neighbor
		if (colC - 1 >= 0 && Enum.at(game.board, rcToId(row, colC - 1)).color != game.turn) do
      pcsToTurn = pcsToTurn ++ checkDirect(game, rowC, colC - 2, "left", pcsToTurn)
		end

		# Check right neighbor
		if (colC + 1 < 8 && Enum.at(game.board, rcToId(row, colC + 1)).color != game.turn) do
      pcsToTurn = pcsToTurn ++ checkDirect(game, rowC, colC + 2, "right", pcsToTurn)
		end

		# Check top neighbor
		if (rowC - 1 < 8 && Enum.at(game.board, rcToId(row - 1, colC)).color != game.turn) do
      pcsToTurn = pcsToTurn ++ checkDirect(game, rowC - 2, colC, "top", pcsToTurn)
		end

		# Check bottom neighbor
		if (rowC + 1 < 8 && Enum.at(game.board, rcToId(row + 1, colC)).color != game.turn) do
      pcsToTurn = pcsToTurn ++ checkDirect(game, rowC + 2, colC, "bottom", pcsToTurn)
		end

      pcsToTurn
	end

	# Given row and column of the board, calculates and retrurns the corresponding id
	defp rcToId(row, column) do
		column + (row * 8)
	end

	# Case of getting out of bounds
	defp checkDirect(game, row, col, pcsToTurn) do
		[]
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells to the left until finds the match, out of
	# bounds or empty cell is encountered
	defp checkDirect(game, row, col, "left", pcsToTurn) do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
        []
			col >= 0 && col < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
          pcsToTurn
				else
					checkDirect(game, row, col - 1, "left", pcsToTurn ++ [rcToId(row, col)])
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells to the right until finds the match, out of
	# bounds or empty cell is encountered
	defp checkDirect(game, row, col, "right", pcsToTurn) do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
        []
			col >= 0 && col < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
          pcsToTurn
				else
					checkDirect(game, row, col + 1, "right", pcsToTurn ++ [rcToId(row, col)])
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells above until finds the match, out of bounds
	# or empty cell is encountered
	defp checkDirect(game, row, col, "top", pcsToTurn) do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
        []
			row >= 0 && row < 8 ->
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
          pcsToTurn
				else
					checkDirect(game, row - 1, col, "top", pcsToTurn ++ [rcToId(row, col)])
				end
			true ->
				checkDirect(game, row, col)
		end
	end

	# Checks if the cell at the given row and column is of the same type(color) as the current
	# player's color. Recursively checks the cells below until finds the match, out of bounds
	# or empty cell is encountered
	defp checkDirect(game, row, col, "bottom", pcsToTurn) do
		cond do
			Enum.at(game.board, rcToId(row, col)).empty ->	# empty cell -> return false
        []
			row >= 0 && row < 8 ->	# valid row
				if (game.turn == Enum.at(game.board, rcToId(row, col)).color) do
          pcsToTurn
				else
					checkDirect(game, row + 1, col, "bottom", pcsToTurn ++ [rcToId(row, col)])
				end
			true ->
				checkDirect(game, row, col)
		end
	end
end
