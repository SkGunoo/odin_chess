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

  def own_king_to_be_checked
    
  end

  def get_king_location(player)
    king = player.pieces.select do |piece|
      piece.piece_type == 'ki'
    end
    king.current_location
  end

  def opponent_player(player)
    player == @board.player_one ? @board.player_two : @board.player_one
  end

  def opponent()
    @current_player == @board.player_one ? @board.player_two : @board.player_one
  end
  
end