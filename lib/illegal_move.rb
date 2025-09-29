require_relative 'winchecker'

class IllegalMove
  def initialize(board, current_player)
    @board = board
    @current_player = current_player
  end

  def illegal_move?(chosen_piece, location)
    if illegal_move_checker(chosen_piece, location)
      @board.display_board
      puts "\n \e[33m That move puts your King in danger! try different move! \e[0m"
      true
    else
      false
    end
  end

  def illegal_move_checker(chosen_piece, location)
    board_copy = Marshal.load(Marshal.dump(@board))
    copied_chosen_piece = find_the_same_piece_from_copy(chosen_piece, board_copy)
    board_copy.move_piece_for_testing(copied_chosen_piece, location)
    current_player = board_copy.players[chosen_piece.player_number]
    winchecker = Winchecker.new(board_copy, current_player, self)
    # winchcker.checked requires updated board
    board_copy.update_board
    winchecker.checked?(current_player)
  end

  def find_the_same_piece_from_copy(chosen_piece, board_copy)
    location = chosen_piece.current_location
    copied_object_board = board_copy.board_with_object
    copied_object_board[location[0]][location[1]]
  end
end
