require_relative 'board.rb'
require_relative 'chess_piece.rb'
require_relative 'winchecker.rb'
require_relative 'illegal_move.rb'
require_relative 'castling.rb'
require_relative 'en_passant.rb'
require_relative 'basic_ai.rb'
require 'yaml'

class ChessGame 

  attr_accessor :turn_number
  attr_reader :illegal_move
  def initialize
    @game_over = false
    @board = Board.new(self)
    @current_player = @board.player_one
    @illegal_move = IllegalMove.new(@board, @current_player)
    @winchecker = Winchecker.new(@board, @current_player, @illegal_move)
    @castling = Castling.new(@board, @winchecker, @current_player)
    @en_passant = EnPassant.new(@board)
    @turn_number = 1
    @game_loaded = false
    
  end

  def illegal_move
    @illegal_move ||= IllegalMove.new(@board, @current_player)
  end

  def play_game
    welcome_message
    load_game? if File.exist?('chess_game.yml')
    vs_player_or_ai unless @game_loaded
    until @game_over
      @board.update_board
      @board.display_board
      ask_player_to_make_a_move(@current_player)
      update_after_a_move()
      @game_over = @winchecker.checkmate_check(@current_player)
      save_game
    end
  end

  def load_game? 

    done = false
    until done
      puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹 \n \e[33m      -Saved game found!-\e[0m \n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
      puts "--Type \e[33m'1'\e[0m then press enter to load \e[32msaved game\e[0m or \n  type \e[33m'2'\e[0m then press enter start a \e[33mnew game\e[0m"
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
      'illegal_move' => @illegal_move,
      'castling' => @castling,
      'en_passant' => @en_passant,
      'turn_number' =>@turn_number,
      'game_loaded' => @game_loaded
    }

    File.write(filename, YAML.dump(data))
    puts "Game saved to #{filename}!"
    # exit
  end

  def load_game(filename = "chess_game.yml")
    return nil unless File.exist?(filename)
    
    data = YAML.load_file(filename, permitted_classes: [
      Board, ChessPiece, Bishop, IllegalMove, King, Knight, Pawn, Player, Queen, Rook, Winchecker,
    EnPassant, Castling, BasicAi, ChessGame],aliases: true)

    @board = data['board']
    @game_over = data['game_over']
    @current_player = data['current_player']
    @winchecker = data['winchecker']
    @illegal_move = data['illegal_move']
    @castling = data['castling']
    @en_passant = data['en_passant']
    @turn_number = data['turn_number']
    @game_loaded = data['game_loaded']
    @game_loaded = true
  rescue => error
    puts "Error loading game: #{error.message}"
    puts "Error type: #{error.class}"
    return nil
  end

  def welcome_message
    
  end

  def ask_player_to_make_a_move(current_player)
    ai_move = current_player.pick_one_random_move if current_player.ai
    chosen_piece = current_player.ai ? ai_move[0] : nil
    location = current_player.ai ? ai_move[1] : nil 
    until chosen_piece && location
      chosen_piece = choose_a_piece(current_player)
      location = get_location_to_move_piece(chosen_piece) 
    end

    if @illegal_move.illegal_move?(chosen_piece, location)
      ask_player_to_make_a_move(current_player)
    else
      @current_player.promote_pawn(chosen_piece, location) if chosen_piece.piece_type == 'pa' && chosen_piece.reached_end?(location)
      @board.move_piece(chosen_piece, location, @turn_number) 
      @castling.castling_check(chosen_piece, location) if chosen_piece.piece_type == 'ki' && @current_player.check == false
      @en_passant.en_passant_check_after_pawn_move(chosen_piece, location) if chosen_piece.piece_type == 'pa'
    end
  end

  def choose_a_piece(current_player)
    #show board again so user can choose the 
    #piece again
    # @board.display_board
    msg_if_player_is_checked(current_player)

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
    puts "\nYou can type \e[33m's'\e[0m and press enter to save the game and exit"
    puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    puts "\e[4m\e[33m-#{@current_player.name}\e[0m, choose which type of chesspiece you want to move."
    puts "--Type the number then press enter:"
    puts "------------------------------------------------"
    puts "---#{array_to_string.join("")}"
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
    @board.display_board(pieces.map{|piece| piece.current_location})
    if locations.size > 1
      puts "\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
      puts "-\e[4m\e[33m#{@current_player.name}\e[0m, which \e[4m\e[32m#{piece_type_user_chose}\e[0m, you want to choose to move?"
      puts "--Type a number and press enter"
      puts "-------------------------------"
      puts "---#{locations.join('')}"
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
    available_locations += @castling.castling_positions(chosen_piece) if chosen_piece.piece_type == 'ki' && @current_player.check == false
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
    # answer = gets.chomp
    # return nil if answer == 'g'
    # valid_location = location_input_check(answer,available_locations)
    valid_location = nil
    until valid_location
      puts " Type\e[31m'g'\e[0m if you want to go back and choose another piece to move  \n"
      puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"      
      puts "-\e[33m#{@current_player.name}\e[0m you can move the piece you chose to one of the \e[43mhighlighted tiles \e[0m"
      puts "--type a location from highlighted tiles(example: a4, d4) then press enter " 
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

  def vs_player_or_ai
    game_mode = get_game_mode_answer
    case game_mode
      when 1 
        nil
      when 2
        player = @board.player_two = BasicAi.new('Basic Ai', 1, @board, self)
        @board.player_two.ai = true
        #players need to be updated 
        #without the update its still player_two
        @board.players[1] = player 
    end
  end

  def get_game_mode_answer
    valid_answer = [1,2,3]
    game_mode = nil
    until game_mode
      puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"      
      puts "-Choose game mode : 1.vs player | 2. vs Bad AI | 3. vs Basic AI "
      puts "--Type a number the press enter"
      answer = gets.chomp.to_i
      game_mode = answer if valid_answer.include?(answer)
    end
    game_mode
  end
end