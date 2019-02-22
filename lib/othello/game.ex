defmodule Othello.Game do
		@start_white_piece1_id 27
		@start_black_piece1_id 28
		@start_white_piece2_id 36
		@start_black_piece2_id 35

#	To keep truck of players turns, we store "black" or "white" in turn,
#	black --> player1's turn  --> black pieces
#	white --> player2's turn  --> white pieces

	def new do
		state =
		%{
			board: [],
			turn: "black",
			player1: "",
			player2: "",
			status: "waiting",
			pcsToTurn: [],
			locAcc: []
		}

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
				status: game.status,
				#pcsToTurn: game.pcsToTurn
			}
		end

		def reset(game) do
			new()
				|> Map.put(:player1, game.player1)
				|> Map.put(:player2, game.player2)
				|> Map.put(:status, "black's turn")
		end

		def addUser(game, userName) do
		# If there is no player1, add player1
		if (game.player1 == "") do
			game
			|> Map.put(:player1, userName)
			|> Map.put(:status, "waiting")

		else  # There is already player1, so we are adding player2
			# handle duplicate name needed???
			if (game.player2 == "" && game.player1 != userName) do
				game
				|> Map.put(:player2, userName)
				|> Map.put(:status, "black's turn")

			else	# There are two players in the game already, so others can just watch
				game
			end
		end
	end

	def handleClick(game, user, id) do
		# Only allow clicking empty cells

		curPlayer =
		case game.turn do
			"black" ->
				game.player1
			"white" ->
				game.player2
		end

		if (Enum.at(game.board, id).empty && game.status != "waiting" && user == curPlayer) do
			thisTurn = game.turn

			nextTurn =
			case game.turn do
				"black" ->
					"white"
				"white" ->
					"black"
			end

			game = findPcsToFlip(game, id)

			# There is somehting to turn based on the valid move
			if (length(game.pcsToTurn) != 0) do

				newBoard = Enum.map(0..63, fn x ->
					if contain(game.pcsToTurn, x) do
						temp = Enum.at(game.board, x)
						|> Map.put(:color, game.turn)
						|> Map.put(:empty, false)
						#List.replace_at(game.board, x, temp)
					else
						Enum.at(game.board, x)
					end
				end)
				game
					|> Map.put(:pcsToTurn, [])
					|> Map.put(:board, newBoard)
					|> Map.put(:status, nextTurn <> "'s turn")
					|> Map.put(:turn, nextTurn)
			else
				game
			end

			# if (noMove(game, nextTurn)) do
			# 	if (noMove(game, thisTurn)) do
			# 			# END GAME
			# 			game
			# 				|> Map.put(:status, "finished")
			# 	else
			# 			# Keep  playing
			# 			game
			# 	end
			# else
			# 	game
			# end
		else
			IO.puts("BAD click")
			game
		end
	end

	# Whether the list contains x
	defp contain(list, x) do
		List.foldl(list, false, fn d, acc ->
			acc || (d == x)
		end)
	end

	def noMove(game, gTurn) do
		game
		|> Map.put(:turn, gTurn)

		Enum.map(0..63, fn x ->
			if (Enum.at(game.board, x).empty) do
				if (length(findPcsToFlip(game, x)) > 0) do
					# There is a valid move for given player
					false
	      end
	  	end
		end)
		true
	end

	# Game, id --> Game
	def findPcsToFlip(game, id) do
	rowC = Enum.at(game.board, id).row
	colC = Enum.at(game.board, id).col

	game
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC, colC - 1, 0, -1)		# left direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC, colC + 1, 0, 1)  		# right direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC - 1, colC, -1, 0)		# top direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC + 1, colC, 1, 0)		# bottom direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC - 1, colC - 1, -1, -1)	# top-left direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC - 1, colC + 1, -1, 1)	# top-right direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC + 1, colC - 1, 1, -1)	# bottom-left direction
	|> Map.put(:locAcc, [rcToId(rowC, colC)])
	|> checkDirect(rowC + 1, colC + 1, 1, 1)	# bottom-right direction
	end

	# Given row and column of the board, calculates and retrurns the corresponding id
	defp rcToId(row, column) do
		column + (row * 8)
	end

	defp validRC(row, col) do
		row >= 0 && row < 8 && col >= 0 && col < 8
	end

	defp checkDirect(game, row, col, rOffset, cOffset) do
		if validRC(row, col) do
			if Enum.at(game.board, rcToId(row, col)).color == game.turn do
			# SAME COLOR --> RETURN
				if (length(game.locAcc) >= 2) do
					game
					|> Map.put(:pcsToTurn, game.pcsToTurn ++ game.locAcc)
					|> Map.put(:locAcc, [])
				else
					game
					|> Map.put(:locAcc, [])
				end
			else
				if Enum.at(game.board, rcToId(row, col)).color == nil do
					# CELL EMPTY
					game
					|> Map.put(:locAcc, [])
				else
					# CELL NOT SAME COLOR
					checkDirect(Map.put(game, :locAcc, game.locAcc ++ [rcToId(row, col)]), row + rOffset, col + cOffset, rOffset, cOffset)
				end
			end
		else
			game
			|> Map.put(:locAcc, [])
		end
	end
end
