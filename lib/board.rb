# rock : Ʀ
# 🅡 Ⓖ
require_relative 'chess_piece'
require_relative 'player.rb'
 

class Board 

  attr_accessor :board, :player_one, :player_two
  def initialize 
    @board = Array.new(8) { Array.new(8)}
    @player_one = Player.new("test",0)
    @player_two = Player.new("test_one",1)

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
    index.even? ? get_row(row,index,alternate_tile[0]): get_row(row,index,alternate_tile[1])
    
  end

  def get_row(row,index,colour_tile_index)
    tile_sction = row.map.with_index do |tile, index| 
      edited_tile = tile.to_s.center(3)
      if colour_tile_index.include?(index)
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
    clear_the_board
    update_chess_piece_locations(@player_one)
    update_chess_piece_locations(@player_two)
  end

  def clear_the_board
    @board = Array.new(8) { Array.new(8)}
  end

  def update_chess_piece_locations(player)
    player.pieces.each do |piece|
      location = piece.current_location
      symbol = piece.symbol
      @board[location[0]][location[1]] = symbol
    end
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