require_relative 'chess_piece'
require_relative 'player'

class Board
  attr_accessor :board, :board_with_object, :player_one, :player_two, :players, :last_four_moves

  def initialize(chess_game)
    # this board is what is shown in terminal
    @board = Array.new(8) { Array.new(8) }
    @chess_game = chess_game
    # this is where chesspiece objects go
    @board_with_object = Array.new(8) { Array.new(8) }

    @player_one = Player.new('Player One', 0, self, @chess_game)
    @player_two = Player.new('Player Two', 1, self, @chess_game)
    @players = [@player_one, @player_two]
    # this used for displaying last 4 moves next to board
    @last_four_moves = [[[], []], [[], []], [[], []], [[], []]]
  end

  def display_board(highlights = [])
    chess_board = []

    @board.each_with_index { |row, index| chess_board << draw_row(row, index, highlights) }
    seperator = "     🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n"

    print_column_numbers('top')
    puts chess_board.join(seperator)
    print_column_numbers('bottom')
  end

  # updates array contents of @board and @board with objects
  def update_board
    update_board_with_object
    update_chess_piece_locations

    @player_one.update_nearby_chesspieces_for_all_pieces(@board_with_object)
    @player_two.update_nearby_chesspieces_for_all_pieces(@board_with_object)
  end

   
  def move_piece(chosen_piece, location, turn_number = 0)
    @last_four_moves << add_move_history(chosen_piece, location, turn_number)
    chosen_piece.location_history << location
    # checks if opponent piece is at the 'location'
    kill_opponent_piece(chosen_piece, location)
    chosen_piece.current_location = location
    chosen_piece.number_of_moves += 1
    chosen_piece.moved = true
  end

  # used when simulating a chess move in other classes
  def move_piece_for_testing(chosen_piece, location)
    chosen_piece.location_history << location
    kill_opponent_piece(chosen_piece, location)
    chosen_piece.current_location = location
    chosen_piece.number_of_moves += 1
  end

  def display_hlighlited_locations(locations, _chosen_piece)
    display_board(locations)
  end


  private

  def draw_row(row, index, hightlights)
    alternate_tile = [[1, 3, 5, 7], [0, 2, 4, 6]]
    if index.even?
      get_row(row, index, alternate_tile[0],
              hightlights)
    else
      get_row(row, index, alternate_tile[1], hightlights)
    end
  end

  def get_row(row, index, colour_tile_index, hightlights)
    tile_sction = row.map.with_index do |tile, current_tile_index|
      edited_tile = tile.to_s.center(3)
      if highlight_check(index, current_tile_index, hightlights)
        "#{background_colour(:yellow, edited_tile)}"
      elsif colour_tile_index.include?(current_tile_index)
        "#{background_colour(:green, edited_tile)}"
      else
        "#{edited_tile}"
      end
    end
    "   #{8 - index} |#{tile_sction.join('|')}| #{8 - index}       #{previous_move_board(index)}\n"
  end

  # there is definetley a better way to do this
  def previous_move_board(row)
    case row
    when 0
      @last_four_moves.reverse[0][0]&.join
    when 1
      @last_four_moves.reverse[0][1]&.join if @last_four_moves.reverse[0][1]
    when 2
      @last_four_moves.reverse[1][0]&.join if @last_four_moves.size > 1
    when 3
      @last_four_moves.reverse[1][1]&.join if @last_four_moves.size > 1 && @last_four_moves.reverse[1][1]
    when 4
      @last_four_moves.reverse[2][0]&.join if @last_four_moves.size > 2
    when 5
      @last_four_moves.reverse[2][1]&.join if @last_four_moves.size > 2 && @last_four_moves.reverse[2][1]
    when 6
      @last_four_moves.reverse[3][0]&.join if @last_four_moves.size > 3
    when 7
      @last_four_moves.reverse[3][1]&.join if @last_four_moves.size > 3 && @last_four_moves.reverse[3][1]
    end
  end

  def print_column_numbers(side)
    # 3 elements
    elements = ["     🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹          🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹\n",
                '       a   b   c   d   e   f   g   h  ',
                ' ']
    puts_order = side == 'top' ? (0..2).to_a.reverse : (0..2).to_a
    puts_order.each { |index| puts elements[index] }
  end

  def background_colour(colour, text)
    colours = {
      green: "\e[42m",
      yellow: "\e[43m"
    }
    reset = "\e[0m"

    "#{colours[colour]}#{text}#{reset}"
  end

  def clear_the_board(selected_board)
    selected_board.each { |row| row.fill(nil) }
  end

  # this updates @board_with_object
  def update_board_with_object
    # fill the board with nil's first after update
    clear_the_board(@board_with_object)

    @player_one.check_for_dead_pieces
    @player_two.check_for_dead_pieces
    all_the_pieces = @player_one.pieces + @player_two.pieces
    all_the_pieces.each do |piece|
      location = piece.current_location
      @board_with_object[location[0]][location[1]] = piece
    end
  end

  # this updates sybols to @board
  def update_chess_piece_locations
    clear_the_board(@board)

    all_the_pieces = @player_one.pieces + @player_two.pieces
    all_the_pieces.each do |piece|
      location = piece.current_location
      symbol = piece.symbol
      @board[location[0]][location[1]] = symbol
    end
  end

  # check if given tile need to be highlighted
  def highlight_check(row, column, highlights)
    highlights.any? { |location| location == [row, column] }
  end

  # set @dead for dead piece and updates previous move board
  # with the captured message 
  def kill_opponent_piece(chosen_piece, location)
    player = chosen_piece.player_number == 1 ? "\e[33mplayer 1\e[0m" : "\e[32mplayer 2\e[0m"
    opponent_piece = @board_with_object[location[0]][location[1]]

    return unless opponent_piece && opponent_piece != chosen_piece

    opponent_piece.dead = true
    @last_four_moves[-1][1] = ["         and captured #{player}'s \e[34m#{opponent_piece.class}\e[0m"]
    @player_one.check_for_dead_pieces
    @player_two.check_for_dead_pieces

  end

  
  # updates previous move board after each move
  def add_move_history(chosen_piece, location, turn_number)
    @last_four_moves.clear if turn_number == 1
    current_location = chosen_piece.convert_array_index_to_chess_location(chosen_piece.current_location)
    moving_location = chosen_piece.convert_array_index_to_chess_location(location)
    player = chosen_piece.player_number == 0 ? "\e[33m#{players[0].name}\e[0m" : "\e[32m#{players[1].name}\e[0m"
    [
      ["\e[31mTurn ##{turn_number}:\e[0m #{player} moved \e[34m#{chosen_piece.class}\e[0m from #{current_location} to #{moving_location}"], []
    ]
  end
end
