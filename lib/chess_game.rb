require_relative 'board.rb'
require_relative 'chess_piece.rb'
require_relative 'winchecker.rb'
require_relative 'illegal_move.rb'
require_relative 'castling.rb'
require_relative 'en_passant.rb'
require 'yaml'

class ChessGame 
  def initialize
    @board = Board.new 
    @game_over = false
    @current_player = @board.player_one
    @winchecker = Winchecker.new(@board, @current_player)
    @illegal_move = IllegalMove.new(@board, @current_player)
    @castling = Castling.new(@board, @winchecker, @current_player)
    @en_passant = EnPassant.new(@board)
    @turn_number = 0
  end

  def play_game
    welcome_message
    load_game? if File.exist?('chess_game.yml')
    until @game_over
      @board.update_board
      @board.display_board
      ask_player_to_make_a_move(@current_player)
      update_after_a_move()
      @game_over = @winchecker.checkmate_check(@current_player)
    end
  end

  def load_game? 
    done = false
    until done
      puts "Saved game found! \n Do you want to load it? press \e[33m'1'\e[0m to load, press \e[33m'2'\e[0m to start a new game"
      answer = gets.chomp.to_s
      done = true if answer == '1'
      return false if answer == '2'
    end
    load_game if done
    
  end

  def save_game(filename = "chess_game.yml")
    data = {
      'board' => @board,
      'game_over' => @game_over,
      'current_player' => @current_player,
      'winchecker' => @winchecker,
      'illegal_move' => @illegal_move
    }
    # YAML.dump converts our object directly to YAML format
    File.write(filename, YAML.dump(data))
    puts "Game saved to #{filename}!"
    exit
  end

  def load_game(filename = "chess_game.yml")
    return nil unless File.exist?(filename)
    
    data = YAML.load_file(filename, permitted_classes: [
      Board, ChessPiece, Bishop, IllegalMove, King, Knight, Pawn, Player, Queen, Rook, Winchecker
    ],aliases: true)

    @board = data['board']
    @game_over = data['game_over']
    @current_player = data['current_player']
    @winchecker = data['winchecker']
    @illegal_move = data['illegal_move']

  rescue => error
    puts "Error loading game: #{error.message}"
    puts "Error type: #{error.class}"  # This helps us see what went wrong
    return nil
  end

  def welcome_message
  end

  def ask_player_to_make_a_move(currnet_player)
    chosen_piece = nil
    location = nil 
    until chosen_piece && location
      msg_if_player_is_checked(currnet_player)
      chosen_piece = choose_a_piece(currnet_player)
      location = get_location_to_move_piece(chosen_piece) 
    end

    if @illegal_move.illegal_move?(chosen_piece, location)
      ask_player_to_make_a_move(currnet_player)
    else
      @castling.castling_check(chosen_piece, location) if chosen_piece.piece_type == 'ki'
      @board.move_piece(chosen_piece, location) 
    end
  end

  def choose_a_piece(current_player)
    choose_the_type(get_available_types(current_player))
  end

  ### need to prevent presenting the pieces has nowhere to go
  def get_available_types(current_player)
    single_letter_to_full = {ki: 'King', qu: 'Queen', kn: 'Knight', bi: 'Bishop', ro: 'Rook', pa: 'Pawn'}
    pieces = current_player.get_pieces_has_movable_places(@board)
    # pieces = current_player.pieces
    pieces.map {|piece| "#{single_letter_to_full[piece.piece_type.to_sym]}"}.uniq()
  end

  def choose_the_type(available_types)
    array_to_string = available_types.map.with_index {|type,index| "#{index + 1}:#{type}  "}
    puts "\nYou can press \e[33m's'\e[0m to save the game and exit"
    puts "\n\e[33m-#{@current_player.name}\e[0m, choose which type of piece to move (enter the number):"
    puts " --#{array_to_string.join("")}"
    piece_type_user_chose = available_types[get_vailid_answer(available_types)]
    #piece_type_user_chose[0] = first letter of the piece i.e k, q, b, ect
    chosen_piece = choose_actual_piece(piece_type_user_chose.downcase)

  end

  def get_vailid_answer(available_types)
    valid_answers = (1..available_types.size).to_a
    answer = gets.chomp
    save_game if answer == 's'
    answer_converted = answer.to_i
    until valid_answers.include?(answer_converted)
      puts "wrong input type between 1 - #{valid_answers[-1]}"
      answer = gets.chomp
      save_game if answer == 's'
      answer_converted = answer.to_i
    end
    # -1 because indext starts at 0
    answer_converted - 1
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
    available_locations = get_available_locations(chosen_piece)
    #when user chose a piece but it has nowhere to go, go back to beginning
    # piece_has_nowhere_to_go(chosen_piece) if available_locations.empty?
    available_chess_locations = convert_array_locations_to_chess_locations(chosen_piece, available_locations)
    @board.display_hlighlited_locations(available_locations, chosen_piece)
    # puts "which location you want to move \e[33m#{chosen_piece.symbol}\e[0m to?"
    user_input = get_location_from_user(available_chess_locations)
    return nil if user_input.nil?
    chosen_piece.convert_chess_location_to_array_location(user_input)
  end
  
  def get_available_locations (chosen_piece)
    available_locations = chosen_piece.get_movable_positions(@board)
    available_locations += @castling.castling_positions(chosen_piece) if chosen_piece.piece_type == 'ki'
    available_locations += @en_passant.en_passant_positions(chosen_piece) if chosen_piece.piece_type == 'pa'
    available_locations
  end

  #converts array of array locations(like [1,0]) to chess location(like a2)
  def convert_array_locations_to_chess_locations(chosen_piece, array_locations)
    converted = array_locations.map {|location|chosen_piece.convert_array_index_to_chess_location(location)}
  end

  def get_location_from_user(available_locations)
    #also need to check if user input is one of the
    #available moves
    answer = gets.chomp
    return nil if answer == 'g'
    valid_location = location_input_check(answer,available_locations)
    until valid_location
      puts "Type\e[33m'g'\e[0m if you want to go back and choose another piece to move  \n"
      puts "type the location from highlighted tiles(example: a4, d4) then press enter " 
      answer = gets.chomp
      return nil if answer == 'g'
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

  

  def update_after_a_move()
    @turn_number += 1
    @en_passant.update_can_get_en_passant(@turn_number)
    @en_passant.update_can_en_passant
    @board.update_board
    # @board.display_board
    @winchecker.update_check_status(@board.player_one)
    @winchecker.update_check_status(@board.player_two)

    switch_player
  end

  def switch_player
    @current_player = @current_player == @board.player_one ? @board.player_two : @board.player_one
  end

  def msg_if_player_is_checked(current_player)
    if @current_player.check 
      puts "\n\e[33m#{'CHECK!'}\e[0m \e[31m#{@current_player.name}\e[0m Your King is under attack!!!!!"
      puts 'you must protect your king in this turn!'
    end
  end

  # def player_still_checked?(chosen_piece, location)
  #   board_backup = Marshal.load(Marshal.dump(@board))
  #   @board.move_piece(chosen_piece, location)
  #   checked = @winchecker.checked?(@current_player)
  #   puts "\n \e[33m#{"this move doesn't save your king, try different move"}\e[0m" if checked
    
  #   @winchecker.back_up_to_original(board_backup) if checked
  #   checked ? true : false
  # end

end