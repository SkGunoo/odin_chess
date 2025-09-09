# require_relative 'bishop.rb'
# require_relative 'pawn.rb'
# require_relative 'king.rb'
# require_relative 'queen.rb'
# require_relative 'knight.rb'
# require_relative 'rock.rb'


class ChessPiece

  attr_accessor :current_location, :symbol, :piece_type, :number_of_moves, :location_history, :player_number, :dead
  SYMBOLS = [["𝐊", "𝐐", "𝐑", "𝐁", "𝐍", "𝐏"],["🅚", "🅠", "🅡", "🅑", "🅝", "🅟"]]
  # SYMBOLS = [["𝐊", "𝐐", "𝐑", "𝐁", "𝐍", "𝐏"],["𝑲", "𝑸", "𝑹", "𝑩", "𝑵", "𝑷"]]

  def initialize(player_number, piece_type, current_location)
    @player_number = player_number
    @piece_type = piece_type
    @symbol = get_symbol(player_number,piece_type)
    @current_location = current_location
    @location_history = [@current_location]
    @number_of_moves = 0
    @dead = false
    # 4 0 5  # each numbers represent index chess piece
    # 1 c 2  #c is chess piece    
    # 6 3 7
    @nearby_pieces = []
    
  end

  def get_symbol(player_number,piece_type)
    symbol_guide = [{k:SYMBOLS[0][0], 
    q:SYMBOLS[0][1],
    r:SYMBOLS[0][2],
    b:SYMBOLS[0][3],
    n:SYMBOLS[0][4],
    p:SYMBOLS[0][5]},
    {k:SYMBOLS[1][0], 
    q:SYMBOLS[1][1],
    r:SYMBOLS[1][2],
    b:SYMBOLS[1][3],
    n:SYMBOLS[1][4],
    p:SYMBOLS[1][5]} 

    ]
    symbol_guide[player_number][piece_type.to_sym]
  end

  def convert_array_index_to_chess_location(array_location)
    convert = {0 => 'a', 1 => 'b', 2 => 'c', 3 => 'd', 4 => 'e', 5 => 'f', 6 => 'g', 7 => 'h'}
    convert_row = {0=>8, 1=>7, 2=>6, 3=>5, 4=>4, 5=>3, 6=>2, 7=>1}
    "#{convert[array_location[1]]}#{convert_row[array_location[0]]}"
  end

  #example: converts d4 into [3,3]
  def convert_chess_location_to_array_location(chess_location)
    convert = {"a"=>0, "b"=>1, "c"=>2, "d"=>3, "e"=>4, "f"=>5, "g"=>6, "h"=>7}
    convert_row = {8 => 0, 7 => 1, 6 => 2, 5 => 3, 4 => 4, 3 =>5, 2=>6,1 =>7}
    [convert_row[(chess_location[1].to_i)] ,convert[chess_location[0]]]
  end

  def update_nearby_chesspieces(board)
    #clear the array so we can update it fresh
    @nearby_pieces.clear
    #top, left,right,bottom, top left, top right, bottom left, bottom right
    offsets = [[-1,0],[0,-1],[0,1],[1,0],[-1,-1],[-1,1],[1,-1],[1,1]]
    offsets.each do |offset| 
      @nearby_pieces << get_piece_from_this_location(board, offset)
    end
  end

  def get_piece_from_this_location(board, offset)
    target_location = [(current_location[0] + offset[0]),(current_location[1] + offset[1])]
    if valid_location?(target_location)
      board[target_location[0]][target_location[1]]
    else
      nil
    end
  end

  def get_locations_of_pieces(pieces)
    locations = []
    
    pieces.each {|piece| locations << piece.current_location } if pieces
    locations
  end

  def valid_location?(location) 
    row = location[0]
    column = location[1]
    valid_range = (0..7)
    if [row, column].all? {|coordinate| valid_range.include?(coordinate) }
      true
    else
      false
    end
  end

  def encountered_own_piece?(next_position,object_board)
    piece = object_board[next_position[0]][next_position[1]] 
    true if own_piece?(piece)
  end
  
  # 
  def tile_has_opponnt_piece?(location, object_board)
    piece = object_board[location[0]][location[1]] 
    true if enemy_piece?(piece)
    
  end

  def enemy_piece?(piece)
    if piece.nil?
      false
    elsif piece.player_number != @player_number
      true
    else
      false
    end
  end

  def own_piece?(piece)
    if piece.nil?
      false
    elsif piece.player_number == @player_number
      true
    else
      false
    end
  end 
end

