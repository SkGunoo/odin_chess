require_relative 'chess_piece'
require_relative 'player.rb'
 

class Board 

  attr_accessor :board, :board_with_object ,:player_one, :player_two
  def initialize 
    @board = Array.new(8) { Array.new(8)}
    #this is where chesspiece objects go 
    @board_with_object = Array.new(8) { Array.new(8)}

    @player_one = Player.new("player_one ",0)
    @player_two = Player.new("player_two",1)

  end

  def display_board(highlights = [])
    chess_board = []
    
    @board.each_with_index {|row, index| chess_board << draw_row(row,index,highlights)}
    seperator = "  🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n"
    
    print_column_numbers("top")
    puts chess_board.join(seperator)
    print_column_numbers("bottom")

  end

  def draw_row(row, index, hightlights)
    alternate_tile =[[1,3,5,7],[0,2,4,6]]
    index.even? ? get_row(row,index,alternate_tile[0],hightlights): get_row(row,index,alternate_tile[1],hightlights)
    
  end

  def get_row(row, index, colour_tile_index, hightlights)
    tile_sction = row.map.with_index do |tile, current_tile_index| 
      edited_tile = tile.to_s.center(3)
      if highlight_check(index, current_tile_index, hightlights)
        "#{background_colour(:yellow,edited_tile)}"
      elsif colour_tile_index.include?(current_tile_index)
        "#{background_colour(:green,edited_tile)}"
      else
        "#{edited_tile}"
      end
    end
    "#{(8 - index)} |#{tile_sction.join("|")}| #{(8 - index)}\n"
  end


  def print_column_numbers(side)
    #3 elements 
    elements = ["  🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n",
    "    a   b   c   d   e   f   g   h  ",
    " "]
    puts_order = side == "top" ? (0..2).to_a.reverse : (0..2).to_a 
    puts_order.each {|index| puts elements[index]}
  end

  
  #colour has to be symbol
  def background_colour(colour, text)
    colours = {
      green:"\e[42m",
      yellow:"\e[43m"
    }
    reset = "\e[0m"

    "#{colours[colour]}#{text}#{reset}"
  end

  def update_board
    # clear_the_board(@board)
    update_board_with_object()
    update_chess_piece_locations()
    
    @player_one.update_nearby_chesspieces_for_all_pieces(@board_with_object)
    @player_two.update_nearby_chesspieces_for_all_pieces(@board_with_object)
  end

  def clear_the_board(selected_board)
    selected_board.each {|row| row.fill(nil)}
  end

  #this updates @board_with_object
  def update_board_with_object()
    #fill the board with nil's first after update
    clear_the_board(@board_with_object)
    
    @player_one.check_for_dead_pieces
    @player_two.check_for_dead_pieces
    all_the_pieces = @player_one.pieces + @player_two.pieces
    all_the_pieces.each do |piece| 
      location = piece.current_location
      @board_with_object[location[0]][location[1]] = piece
    end
  end

 
  #this updates sybols to @board
  def update_chess_piece_locations()
    clear_the_board(@board)

    all_the_pieces = @player_one.pieces + @player_two.pieces
    all_the_pieces.each do |piece|
      location = piece.current_location
      symbol = piece.symbol
      @board[location[0]][location[1]] = symbol
    end
  end

  def highlight_check(row,column,highlights)
    highlights.any? {|location| location == [row,column]}
  end

  def kill_opponent_piece(chosen_piece, location)
    if opponent_piece = @board_with_object[location[0]][location[1]]
      opponent_piece.dead = true
    end
    # chosen_piece.current_location = location
  end

  def display_hlighlited_locations(locations)
    display_board(locations)
    puts "you can move the piece to highlited tiles"
    puts "type the location(example: a4, d4) then press enter" 
  end

  

end


# def print_top_row
  #   numbers = (1..8).to_a.map {|num| "#{num.to_s.center(4)}"}
  #   puts "\n   " + numbers.join("")
  #   seperator = "  🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n"
  #   puts seperator
  # end

  # def print_bottom_row
  #   numbers = (1..8).to_a.map {|num| "#{num.to_s.center(4)}"}
  #   seperator = "  🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n"
  #   puts seperator
  #   puts "   " + numbers.join("") 
  #   puts " "
  # end