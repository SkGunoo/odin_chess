require_relative 'board'
require_relative 'chess_piece'
require_relative 'winchecker'
require_relative 'illegal_move'
require_relative 'castling'
require_relative 'en_passant'
require_relative 'basic_ai'
require_relative 'good_ai'
require 'yaml'

class ChessGame
  attr_accessor :turn_number, :winchecker
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

  #basic game loop
  def play_game
    welcome_message
    load_game? if File.exist?('chess_game.yml')
    vs_player_or_ai unless @game_loaded
    until @game_over
      @board.update_board
      @board.display_board
      ask_player_to_make_a_move(@current_player)
      update_after_a_move
      @game_over = @winchecker.checkmate_check(@current_player) if @current_player.check
      @game_over = @winchecker.stalemate_check(@current_player, @turn_number)
    end
  end

  private

  def load_game?
    answered = false
    until answered
      puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹 \n \e[33m      -Saved game found!-\e[0m \n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
      puts "--Type \e[33m'1'\e[0m then press enter to load \e[32msaved game\e[0m or \n  type \e[33m'2'\e[0m then press enter start a \e[33mnew game\e[0m"
      answer = gets.chomp.to_s
      answered = true if answer == '1'
      return false if answer == '2'
    end
    load_game if answered
  end

  def save_game(filename = 'chess_game.yml')
    data = {
      'board' => @board,
      'game_over' => @game_over,
      'current_player' => @current_player,
      'winchecker' => @winchecker,
      'illegal_move' => @illegal_move,
      'castling' => @castling,
      'en_passant' => @en_passant,
      'turn_number' => @turn_number,
      'game_loaded' => @game_loaded
    }

    File.write(filename, YAML.dump(data))
    puts "Game saved to #{filename}!"
    exit
  end

  #permitted_classes and aliases property is
  #required to load all the classes and its
  #intstnaces properly
  def load_game(filename = 'chess_game.yml')
    return nil unless File.exist?(filename)

    data = YAML.load_file(filename, permitted_classes: [
                            Board, ChessPiece, Bishop, IllegalMove, King, Knight, Pawn, Player, Queen, Rook, Winchecker,
                            EnPassant, Castling, BasicAi, ChessGame, GoodAi, Symbol
                          ], aliases: true)

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
  rescue StandardError => e
    puts "Error loading game: #{e.message}"
    puts "Error type: #{e.class}"
    nil
  end

  def welcome_message
    puts "\n\n\n\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹 \n \e[33m      -Welcome to Chess!-\e[0m \n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    puts 'Please, read the instructions properly!'
    puts "Thank you for playting and good luck! \n\n\n"
  end

  # main method handles getting a move from player or ai 
  def ask_player_to_make_a_move(current_player)
    # get a move from ai if current player is ai
    ai_move = current_player.pick_one_move if current_player.ai
    chosen_piece = current_player.ai ? ai_move[0] : nil
    location = current_player.ai ? ai_move[1] : nil
    
    # get user input if current_player is not ai
    until chosen_piece && location
      chosen_piece = choose_a_piece(current_player)
      location = get_location_to_move_piece(chosen_piece)
    end

    # if the move puts king in danger ask user again to pick a move
    if @illegal_move.illegal_move?(chosen_piece, location)
      ask_player_to_make_a_move(current_player)
    # if its a valid move then check various conditions depends on
    # type of the chesspiece, like en_passant, pawn promotion and castling
    else
      if chosen_piece.piece_type == 'pa' && chosen_piece.reached_end?(location)
        @current_player.promote_pawn(chosen_piece, location)
      end
      @board.move_piece(chosen_piece, location, @turn_number)
      if chosen_piece.piece_type == 'ki' && @current_player.check == false
        @castling.castling_check(chosen_piece, location)
      end
      @en_passant.en_passant_check_after_pawn_move(chosen_piece, location) if chosen_piece.piece_type == 'pa'
    end
  end


  def choose_a_piece(current_player)
    # if player is in check, warn user about it
    msg_if_player_is_checked(current_player)

    choose_the_type(get_available_types(current_player))
  end

  # prevents user from choosing a piece that has nowhere go to
  def get_available_types(current_player)
    single_letter_to_full = { ki: 'King', qu: 'Queen', kn: 'Knight', bi: 'Bishop', ro: 'Rook', pa: 'Pawn' }
    pieces = current_player.get_pieces_has_movable_places(@board)
    pieces.map { |piece| "#{single_letter_to_full[piece.piece_type.to_sym]}" }.uniq
  end

  # ask user what 'type' of chesspiece they want to move
  # before choosing a exact piece
  def choose_the_type(available_types)
    array_to_string = available_types.map.with_index { |type, index| "#{index + 1}:#{type}  " }
    puts "\nYou can type \e[33m's'\e[0m and press enter to save the game and exit"
    puts '🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹'
    puts "\e[4m\e[33m-#{@current_player.name}\e[0m, choose which type of chesspiece you want to move."
    puts '--Type the number then press enter:'
    puts '------------------------------------------------'
    puts "---#{array_to_string.join('')}"
    piece_type_user_chose = available_types[get_vailid_answer(available_types)]
    choose_actual_piece(piece_type_user_chose.downcase)
  end

  ##refactor
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

  # after user choosing the 'type' of chesspiece
  # ask them to choose which specific piece of that type they want to move
  def choose_actual_piece(piece_type_user_chose)
    pieces = @current_player.get_positions_of_pieces(piece_type_user_chose[0..1])
    # this filters the pieces that has no places to go prevent users from choosing it
    pieces = pieces.select { |piece| piece.get_movable_positions(@board).size > 1 }
    locations = pieces.map.with_index do |piece, index|
      "#{index + 1}:#{piece.convert_array_index_to_chess_location(piece.current_location)}  "
    end
    @board.display_board(pieces.map { |piece| piece.current_location })
    if locations.size > 1
      puts "\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
      puts "-\e[4m\e[33m#{@current_player.name}\e[0m, which \e[4m\e[32m#{piece_type_user_chose}\e[0m, you want to choose to move?"
      puts '--Type a number and press enter'
      puts '-------------------------------'
      puts "---#{locations.join('')}"
      pieces[get_vailid_answer(locations)]
    else
      pieces[0]
    end
  end

  # after user chose the specific piece they want to move
  # present them which a board with locations that piece can go highlighted
  # so the user can choose the exact location they want it to move
  def get_location_to_move_piece(chosen_piece)
    available_locations = get_available_locations(chosen_piece)
    available_chess_locations = convert_array_locations_to_chess_locations(chosen_piece, available_locations)
    @board.display_hlighlited_locations(available_locations, chosen_piece)
    # puts "which location you want to move \e[33m#{chosen_piece.symbol}\e[0m to?"
    user_input = get_location_from_user(available_chess_locations)
    return nil if user_input.nil?

    chosen_piece.convert_chess_location_to_array_location(user_input)
  end

  # check caslting and en passant availability here
  # so we can add them to available moves, so user can see 
  # those options are available
  def get_available_locations(chosen_piece)
    available_locations = chosen_piece.get_movable_positions(@board)
    if chosen_piece.piece_type == 'ki' && @current_player.check == false
      available_locations += @castling.castling_positions(chosen_piece)
    end
    available_locations += @en_passant.en_passant_positions(chosen_piece) if chosen_piece.piece_type == 'pa'
    available_locations
  end

  # converts array of array locations(like [1,0]) to chess location(like a2)
  def convert_array_locations_to_chess_locations(chosen_piece, array_locations)
    array_locations.map { |location| chosen_piece.convert_array_index_to_chess_location(location) }
  end

  # user choose the location to move their chosen piece
  # if user decide to choose another piece to move they can
  # type 'g' here to go back to choose 'type' of the chesspiece again
  def get_location_from_user(available_locations)
    valid_location = nil
    until valid_location
      puts " Type\e[31m'g'\e[0m if you want to go back and choose another piece to move  \n"
      puts '🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹'
      puts "-\e[33m#{@current_player.name}\e[0m you can move the piece you chose to one of the \e[43mhighlighted tiles \e[0m"
      puts '--type a location from highlighted tiles(example: a4, d4) then press enter '
      answer = gets.chomp.downcase
      if answer == 'g'
        @board.display_board
        return nil
      end
      valid_location = location_input_check(answer, available_locations)
    end
    answer
  end

  # checks if user's chess location input is correct
  def location_input_check(location, available_locations)
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a
    # available_locations[1..-1] because first element is current location
    if columns.include?(location[0]) && rows.include?(location[1]) && location.size == 2 && available_locations[1..-1].include?(location)
      true
    end
  end

  # updates all the necessary instances variables after user made a move
  def update_after_a_move
    @turn_number += 1
    @en_passant.update_can_get_en_passant(@turn_number)
    @en_passant.update_can_en_passant
    @board.update_board
    @winchecker.update_check_status(@board.player_one)
    @winchecker.update_check_status(@board.player_two)

    switch_player
  end

  def switch_player
    @current_player = @current_player == @board.player_one ? @board.player_two : @board.player_one
  end

  def msg_if_player_is_checked(_current_player)
    return unless @current_player.check

    puts "\n\e[33mCHECK!\e[0m \e[31m#{@current_player.name}\e[0m Your King is under attack!!!!!"
    puts 'you must protect your king in this turn!'
  end

  # ask user if they want to play agains other player or ai
  def vs_player_or_ai
    game_mode = get_game_mode_answer
    case game_mode
    when 1
      nil
    when 2
      player = @board.player_two = BasicAi.new('Dumb Ai', 1, @board, self)
      @board.player_two.ai = true
      # players need to be updated
      # without the update its still player_two
      @board.players[1] = player

    when 3
      player = @board.player_two = GoodAi.new('O-kay Ai', 1, @board, self)
      @board.player_two.ai = true
      # players need to be updated
      # without the update its still player_two
      @board.players[1] = player

      # ai vs ai test
      # uncomment lines below if you want to test ai vs ai
      # player_one = @board.player_one = BasicAi.new('Basic Ai 2', 0, @board, self)
      # @board.player_one.ai = true
      # @board.players[0] = player_one
      # @current_player = player_one

    end
  end

  def get_game_mode_answer
    valid_answer = [1, 2, 3]
    game_mode = nil
    until game_mode
      puts '🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹'
      puts "-Choose game mode : \e[33m1.vs player\e[0m | \e[34m2. play vs Dumb AI\e[0m | \e[35m3. play vs O-kay AI\e[0m "
      puts '--Type a number the press enter'
      answer = gets.chomp.to_i
      game_mode = answer if valid_answer.include?(answer)
    end
    game_mode
  end
end
