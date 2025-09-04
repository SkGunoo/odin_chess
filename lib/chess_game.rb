require_relative 'board.rb'
require_relative 'chess_piece'

class ChessGame 
  def initialize
    @board = Board.new 
    @game_over = false
    @current_player = @board.player_one
  end

  def play_game
    welcome_message
    until @game_over
      # @board.update_board
      # @board.display_board
      ask_player_to_make_a_move(@current_player)
    end
  end

  def welcome_message
  end

  def ask_player_to_make_a_move(currnet_player)
    #first choose which piece playr want to move
    #then show which locations that piece can go 
    #make sure to give option to go back to choose
    #differnt piece
    chosen_piece = choose_a_piece(currnet_player)
    #add a method that displays available locations
    #that chosen piece can move
    location = get_location_to_move_piece(chosen_piece)
    move_piece(chosen_piece,location)
  end

  def choose_a_piece(current_player)
    choose_the_type(get_available_types(current_player))
  end

  def get_available_types(current_player)
    single_letter_to_full = {k: 'king', q: 'queen', n: 'knight', b: 'bishop', r: 'rock', p: 'pawn'}
    pieces = current_player.pieces
    pieces.map {|piece| "#{single_letter_to_full[piece.piece_type.to_sym]}"}.uniq()
  end

  def choose_the_type(available_types)
    array_to_string = available_types.map.with_index {|type,index| "#{index + 1}:#{type}  "}
    puts "-Choose the number for type of the Chesspiece then press enter"
    puts "--#{array_to_string.join("")}"
    piece_type_user_chose = available_types[get_vailid_answer(available_types)]
    #piece_type_user_chose[0] = first letter of the piece i.e k, q, b, ect
    chosen_piece = choose_actual_piece(piece_type_user_chose)

  end

  def get_vailid_answer(available_types)
    valid_answers = (1..available_types.size).to_a
    # answer = nil
    answer = gets.chomp.to_i
    until valid_answers.include?(answer)
      puts "wrong input type between 1 - #{valid_answers[-1]}"
      answer = gets.chomp.to_i
    end
    # -1 because indext starts at 0
    answer - 1
  end

  def choose_actual_piece(piece_type_user_chose)
    pieces = @current_player.get_positions_of_pieces(piece_type_user_chose[0])
    locations = pieces.map.with_index {|piece,index| "#{index + 1}:#{piece.convert_array_index_to_chess_location(piece.current_location)}  "}
    if locations.size > 1
      puts "-which #{piece_type_user_chose}, you want to choose to move?"
      puts "--#{locations.join('')}"
      pieces[get_vailid_answer(locations)]
    else
      pieces[0]
    end
  end

  def get_location_to_move_piece(chosen_piece)
    puts "which location you want to move #{chosen_piece.symbol} to?"
    @board.display_board
    puts "type the location(example: a4, d4) then press enter" 
    chosen_piece.convert_chess_location_to_array_location(get_location_from_user())
  end

  def get_location_from_user()
    #also need to check if user input is one of the
    #available moves
    valid_location = false
    answer = gets.chomp
    valid_location = location_input_check(answer)
    until valid_location
      puts "type the location(example: a4, d4) then press enter" 
      answer = gets.chomp
      valid_location = location_input_check(answer)
    end
    answer
  end

  #checks if user input is correct
  def location_input_check(location)
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a
    true if columns.include?(location[0]) && rows.include?(location[1]) && location.size == 2 
  end
  def move_piece(chosen_piece, location)
    chosen_piece.current_location = location
    @board.update_board
    @board.display_board
    switch_player
  end

  def switch_player
    @current_player = @current_player == @board.player_one ? @board.player_two : @board.player_one
  end
end