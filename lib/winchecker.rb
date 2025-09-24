class Winchecker
  
  def initialize(board, current_player, illegal_move)
    @board = board
    @current_player = current_player
    @illegal_move = illegal_move
  end

  # def checked?()
  #   opponent_king_location = get_king_location(opponent())

  #   @current_player.pieces.any? do |piece|
  #     locations = piece.get_movable_positions(@board)
  #     locations.include?(opponent_king_location)
  #   end
  # end
  
  #this check if given play's king is checked
  def checked?(player)
    opponent = opponent_player(player)
    king_location = get_king_location(player)
    
    opponent.pieces.any? do |piece|
      locations = piece.get_movable_positions(@board)
      locations.include?(king_location)
    end
  end

  def king_cannot_escape_check?(player)
    king = get_king(player)
    king_movable_locations = king.get_movable_positions(@board) 
    # board_backup = Marshal.load(Marshal.dump(@board))
    locations_opponent_can_reach = get_all_possible_locations_from_all_pieces(opponent_player(player))
    king_movable_locations.all? do |location|
      locations_opponent_can_reach.include?(location)
    end
  end

  def get_all_possible_locations_from_all_pieces(player)
    locations = []
    player.pieces.each do |piece|
      locations += piece.get_movable_positions(@board)
    end
    locations
  end
  
  def get_king(player)
    king = player.pieces.select do |piece|
      piece.piece_type == 'ki'
    end
    king[0]
  end

  def update_check_status(player)
    if checked?(player)
      player.check = true
    else
      player.check = false
    end 
  end

  

  def get_king_location(player)
    king = player.pieces.select do |piece|
      piece.piece_type == 'ki'
    end
    king[0].current_location
  end

  

  def opponent_player(player)
    player == @board.player_one ? @board.player_two : @board.player_one
  end

  def opponent()
    @current_player == @board.player_one ? @board.player_two : @board.player_one
  end

  def back_up_to_original(board_backup)
      @board.player_one.pieces = board_backup.player_one.pieces
      @board.player_two.pieces = board_backup.player_two.pieces
      # @board = board_backup
      @board.update_board
      update_check_status(@board.player_one)
      update_check_status(@board.player_two)
  end

  def checkmate_check(player)
    if king_cannot_escape_check?(player) && can_anyone_save_king?(player)
      opponent = opponent_player(player)
      puts "\e[31m#{'CHECKMATE!'}\e[0m ,\e[33m#{opponent.name}\e[0m  WON"
      true
    else
      false
    end
  end

  def can_anyone_save_king?(player)
    get_all_the_moves = get_all_possible_locations_from_all_pieces(player)
    get_all_the_moves.any? do |move|
      piece = move[0]
      location = move[1]
      @illegal_move.illegal_move_checker(piece, location)
    end
  end

  def get_all_possible_moves_of_all_pieces(player)
    moves =[]
    player.pieces.each do |piece|
      piece_moves = piece.get_movable_positions(@board)
      next if piece_moves.size < 2
      piece_moves[1..-1].each {|move| moves << [piece, move] }
    end
    moves
  end


end