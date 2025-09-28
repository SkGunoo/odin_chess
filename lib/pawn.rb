require_relative 'chess_piece.rb'

class Pawn < ChessPiece

  attr_accessor :can_en_passant, :can_get_en_passant, :just_en_passanted, :first_moved_turn
  def initialize(player_number, piece_type, current_location)
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
      movable_positions = movable_positions + [@current_location] + catchable_chesspieces 
    else
      movable_positions = forward_locations(board) + catchable_chesspieces
    end
    movable_positions
    # [[6, 0],[4,0],[5,0]]
  end

  

  def pick_piece(name)
    vaild_answers = [1,2,3,4]
    answer = nil
    until vaild_answers.include?(answer)
      puts "\e[33m #{name} \e[0m your pawn reached the end, pick piece to promote your pawn."
      puts "1: Knight, 2: Bishop, 3: Rook, 4: Queen "
      answer = gets.chomp.to_i
    end
    answer - 1
  end

  def possible_pawn_catchable_places()
    places = []
    
    offsets = @player_number.zero? ? [[-1,-1],[-1,1]] : [[1,-1],[1, 1]]
    offsets.each do |offset|
      row = @current_location[0] + offset[0]
      column = @current_location[1]+ offset[1]
      places << [self,[row , column]] if valid_location?([row, column]) 
    end
    places
  end
  
  def reached_end?(location)
    end_location = @player_number == 0 ? 0 : 7
    true if location[0] == end_location
  end

  private 

  def forward_locations(board)
    location = @current_location
    second_tile = [location[0] + switch_direction_depends_on_player(2),location[1]]
    
    if @number_of_moves == 0 && board.board_with_object[second_tile[0]][second_tile[1]].nil?
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