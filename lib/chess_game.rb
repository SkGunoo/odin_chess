require_relative 'board.rb'
require_relative 'chess_piece.rb'
require_relative 'winchecker.rb'

class ChessGame 
  def initialize
    @board = Board.new 
    @game_over = false
    @current_player = @board.player_one
    @winchekcer = Winchecker.new(@board, @current_player)
  end

  def play_game
    welcome_message
    until @game_over
      @board.update_board
      @board.display_board
      ask_player_to_make_a_move(@current_player)
    end
  end

  def welcome_message
  end

  def ask_player_to_make_a_move(currnet_player)
    # puts " hohohoho" if @winchekcer.checked?(currnet_player)
    msg_if_player_is_checked(currnet_player)
    chosen_piece = choose_a_piece(currnet_player)
    location = get_location_to_move_piece(chosen_piece)
    #go back if this move doesnt get player out of check
    ask_player_to_make_a_move(currnet_player) if player_still_checked?(chosen_piece, location)
    move_piece(chosen_piece, location)
    update_after_a_move(chosen_piece, location)
  end

  def choose_a_piece(current_player)
    choose_the_type(get_available_types(current_player))
  end

  ### need to prevent presenting the pieces has nowhere to go
  def get_available_types(current_player)
    single_letter_to_full = {ki: 'king', qu: 'queen', kn: 'knight', bi: 'bishop', ro: 'rock', pa: 'pawn'}
    pieces = current_player.get_pieces_has_movable_places(@board)
    # pieces = current_player.pieces
    pieces.map {|piece| "#{single_letter_to_full[piece.piece_type.to_sym]}"}.uniq()
  end

  def choose_the_type(available_types)
    array_to_string = available_types.map.with_index {|type,index| "#{index + 1}:#{type}  "}
    puts "-#{@current_player.name} Choose the number for type of the Chesspiece then press enter"
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
    pieces = @current_player.get_positions_of_pieces(piece_type_user_chose[0..1])
    #this filters the pieces that has no play to go
    pieces = pieces.select {|piece| piece.get_movable_positions(@board).size > 1}
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
    available_locations = chosen_piece.get_movable_positions(@board)
    #when user chose a piece but it has nowhere to go, go back to beginning
    piece_has_nowhere_to_go(chosen_piece) if available_locations.empty?
    available_chess_locations = convert_array_locations_to_chess_locations(chosen_piece, available_locations)
    @board.display_hlighlited_locations(available_locations)
    chosen_piece.convert_chess_location_to_array_location(get_location_from_user(available_chess_locations))
  end
  
  def piece_has_nowhere_to_go(chosen_piece)
    puts "-#{chosen_piece.symbol}- you chose has nowhere to go"
    puts "going back"
    ask_player_to_make_a_move(@current_player)
  end
  #converts array of array locations(like [1,0]) to chess location(like a2)
  def convert_array_locations_to_chess_locations(chosen_piece, array_locations)
    converted = array_locations.map {|location|chosen_piece.convert_array_index_to_chess_location(location)}
  end

  def get_location_from_user(available_locations)
    #also need to check if user input is one of the
    #available moves
    answer = gets.chomp
    valid_location = location_input_check(answer,available_locations)
    until valid_location
      puts "type the location(example: a4, d4) then press enter" 
      answer = gets.chomp
      valid_location = location_input_check(answer,available_locations)
    end
    answer
  end

  #checks if user input is correct
  def location_input_check(location,available_locations)
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a
    #available_locations[1..-1] because first element is current location
    true if columns.include?(location[0]) && rows.include?(location[1]) && location.size == 2 && available_locations[1..-1].include?(location)
  end

  #move the given piece to specific location
  def move_piece(chosen_piece, location)
    chosen_piece.location_history << location
    @board.kill_opponent_piece(chosen_piece, location)
    chosen_piece.current_location = location
    chosen_piece.number_of_moves += 1

  end

  def update_after_a_move(chosen_piece, location)
    @board.update_board
    @board.display_board
    @winchekcer.update_check_status(@board.player_one)
    @winchekcer.update_check_status(@board.player_two)

    switch_player
  end

  def switch_player
    @current_player = @current_player == @board.player_one ? @board.player_two : @board.player_one
  end

  def msg_if_player_is_checked(current_player)
    if @current_player.check 
      puts "CHECK!  Your King is under attack!!!!!"
      puts " you must protect your king in this turn!"
    end
  end

  def player_still_checked?(chosen_piece, location)
    board_backup = Marshal.load(Marshal.dump(@board))
    move_piece(chosen_piece, location)
    checked = @winchekcer.checked?(@current_player)
    puts "your king is still checked, try different move"
    # @board = board_backup
    if checked
      @board.player_one.pieces = board_backup.player_one.pieces
      @board.player_two.pieces = board_backup.player_two.pieces
    end

    checked ? true : false
  end
end