class Winchecker
  
  def initialize(board, current_player)
    @board = board
    @current_player = current_player
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

  def king_can_escape_check?(player)
    king = get_king(player)

  end
  
  def get_king(player)
    king = player.pieces.select do |piece|
      piece.piece_type == 'ki'
    end
    king
  end

  def update_check_status(player)
    player.check = true if checked?(player)
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
end