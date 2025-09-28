require_relative 'chess_piece.rb'

class Bishop < ChessPiece

  def get_movable_positions(board)
    object_board = board.board_with_object
    movable_positions = [@current_location]
    offsets = [[-1, -1], [-1, 1],[1, -1],[1, 1]]
    offsets.each do |direction|
      locations = get_available_locations_to_given_direction(direction,object_board)
      movable_positions += locations
    end
    movable_positions
  end

  private

  def get_available_locations_to_given_direction(direction, object_board)
    locations = []
    next_position = get_next_direction(@current_location, direction)
    until !valid_location?(next_position) || encountered_own_piece?(next_position, object_board)
      locations << next_position
      next_position = get_next_direction(next_position, direction)
      break if tile_has_opponnt_piece?(locations[-1], object_board)
    end
    locations
  end

  def get_next_direction(location, direction)
    next_row = location[0] + direction[0]
    next_column = location[1] + direction[1]
    [next_row, next_column]
  end

end