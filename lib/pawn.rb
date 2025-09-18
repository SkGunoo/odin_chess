require_relative 'chess_piece.rb'

class Pawn < ChessPiece

  attr_accessor :can_en_passant, :can_get_en_passant, :just_en_passanted, :first_moved_turn
  def initialize(player_number,piece_type, current_location)
    super(player_number , 'pa', current_location)
    @can_en_passant = false
    @can_get_en_passant = false
    @just_en_passanted = false
    @first_moved_turn = nil 
  end

  def get_movable_positions(board)
    #pawn should be movable diagonally if there
    #is a catchable piece
    movable_positions = []
    if blocked_by_another_piece?
      movable_positions = movable_positions + catchable_chesspieces
    else
      movable_positions = forward_locations + catchable_chesspieces
    end
    movable_positions
    # [[6, 0],[4,0],[5,0]]
  end

  def forward_locations 
    location = @current_location
    if @number_of_moves == 0
      [location,[location[0] + switch_direction_depends_on_player(1),@current_location[1]],[location[0] + switch_direction_depends_on_player(2),location[1]]]

    else
      [location,[location[0] + switch_direction_depends_on_player(1),location[1]]]
    end
  end

  def blocked_by_another_piece?
    index = @player_number == 0 ? 0 : 3
    @nearby_pieces[index] == nil ? false : true
  end

  def catchable_chesspieces
    indexes = @player_number == 0 ? [4, 5] : [6, 7]
    catchable_pieces = []
    indexes.each do |index|
      if @nearby_pieces[index] && @nearby_pieces[index].player_number != @player_number
        catchable_pieces << @nearby_pieces[index] 
      else
      end
    end
    get_locations_of_pieces(catchable_pieces) 
  end

  def switch_direction_depends_on_player(num)
    @player_number == 0 ? num * -1 : num
  
  end
end