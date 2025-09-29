require_relative 'chess_piece'

class Knight < ChessPiece
  def get_movable_positions(board)
    object_board = board.board_with_object
    movable_positions = [@current_location]
    offsets = [[-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2]]
    offsets.each do |direction|
      location = get_available_location_to_given_direction(direction, object_board)
      movable_positions << location unless location.nil?
    end
    movable_positions
  end

  private

  def get_available_location_to_given_direction(direction, object_board)
    location = get_next_direction(@current_location, direction)
    location if valid_location?(location) && !encountered_own_piece?(location, object_board)
  end

  def get_next_direction(location, direction)
    next_row = location[0] + direction[0]
    next_column = location[1] + direction[1]
    [next_row, next_column]
  end
end
