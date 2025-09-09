require_relative 'lib/board.rb'
require_relative 'lib/chess_piece.rb'
require_relative 'lib/chess_game.rb'
require_relative 'lib/bishop.rb'
require_relative 'lib/pawn.rb'
require_relative 'lib/king.rb'
require_relative 'lib/queen.rb'
require_relative 'lib/knight.rb'
require_relative 'lib/rock.rb'

# a = Board.new
# a.update_board
# a.display_board
b = ChessGame.new
b.play_game