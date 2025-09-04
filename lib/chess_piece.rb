require_relative 'bishop.rb'
require_relative 'pawn.rb'
require_relative 'king.rb'
require_relative 'queen.rb'
require_relative 'knight.rb'
require_relative 'rock.rb'


class ChessPiece

  attr_accessor :current_location, :symbol, :piece_type
  SYMBOLS = [["𝐊", "𝐐", "𝐑", "𝐁", "𝐍", "𝐏"],["🅚", "🅠", "🅡", "🅑", "🅝", "🅟"]]
  # SYMBOLS = [["𝐊", "𝐐", "𝐑", "𝐁", "𝐍", "𝐏"],["𝑲", "𝑸", "𝑹", "𝑩", "𝑵", "𝑷"]]

  def initialize(player_number,piece_type,current_location)
    @player_number = player_number
    @piece_type = piece_type
    @symbol = get_symbol(player_number,piece_type)
    @current_location = current_location
    
    
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
    "#{convert[array_location[1]]}#{array_location[0] + 1}"
  end

  #example: converts d4 into [3,3]
  def convert_chess_location_to_array_location(chess_location)
    convert = {"a"=>0, "b"=>1, "c"=>2, "d"=>3, "e"=>4, "f"=>5, "g"=>6, "h"=>7}
    convert_row = {8 => 0, 7 => 1, 6 => 2, 5 => 3, 4 => 4, 3 =>5, 2=>6,1 =>7}
    [convert_row[(chess_location[1].to_i)] ,convert[chess_location[0]]]

  end
end

