class Castling
  
  def initialize(board, winchecker, current_player)
    @board = board
    @winchcker = winchecker
    @board_with_object = @board.board_with_object
    @locations = [[[7, 6],[7, 2]],[[0, 6],[0, 2]]]
    @player_one = [[[7, 5], [7, 6]], [[7, 1],[7, 2], [7, 3]]]
    @player_two = [[[0, 5], [0, 6]], [[0, 1],[0, 2], [0, 3]]]
    @rook_location = [[[7, 7],[7, 0]],[[0, 7],[0, 0]]]
    @rook_moving_location = [[[7, 5],[7, 3]],[[0, 5],[0, 3]]]
  end

  def castling_check(chosen_piece, input_location)
    player = @board.players[chosen_piece.player_number]
    rook_location = get_rook_location(input_location, @rook_location, player)
    rook = player.pieces.select { |piece| piece.current_location == rook_location}
    rook_location_to_move_to = get_rook_location(input_location, @rook_moving_location, player)
    if rook[0] != nil
      @board.move_piece(rook[0], rook_location_to_move_to) 
      @board.last_four_moves[-1][1] = ["#{player.name} used castling"]  
    end
    
    
  end

  def castling_positions(chosen_piece)
    castling_info = get_castling_info(chosen_piece)
    if castling_info[0] 
      get_castling_locations(castling_info, chosen_piece)
    else
      []
    end
    
  end

  private 
  
  def get_rook_location(input_location, rook_location, player)
    locations = @locations[player.player_number]
    rook_locations = rook_location[player.player_number]
    return unless locations.include?(input_location) 
    locations[0] == input_location ? rook_locations[0] : rook_locations[1]
  end


  def get_castling_locations(castling_info, chosen_piece)
    player = @board.players[chosen_piece.player_number]
    current_player_index = player.player_number

    if castling_info[1] && castling_info[2]
      @locations[current_player_index]
    elsif castling_info[0] && castling_info[1] == false
      [@locations[current_player_index][1]]
    else
      [@locations[current_player_index][0]]
    end

  end

  #chosen piece will be a king
  def get_castling_info(chosen_piece)
    player = @board.players[chosen_piece.player_number]

    king_can_castle = chosen_piece.number_of_moves == 0 && !@winchcker.checked?(player)    #this is in a array form [boolean, boolean]
    rooks_can_castle = rook_can_castle?(chosen_piece)
    result = king_can_castle && rooks_can_castle.any? {|element| element == true}
    [result, rooks_can_castle[0],rooks_can_castle[1]]
  end

  def rook_can_castle?(chosen_piece)    
    player = @board.players[chosen_piece.player_number]
    
    rooks_never_moved = rook_move_check(chosen_piece)
    empty_space_btw_king_rook = empty_space_check(rooks_never_moved, player)
    empty_is_reachable = empty_space_reachable(player)
    left_side = final_check(rooks_never_moved, empty_space_btw_king_rook, empty_is_reachable, 0)
    right_side = final_check(rooks_never_moved, empty_space_btw_king_rook, empty_is_reachable, 1)
    [left_side, right_side]
  end

  def final_check(moved, empty, reachable, index)
    if moved[index] && empty[index] && reachable[index]
      true
    else
      false
    end
  end

  def empty_space_reachable(player)
    locations = player.player_number == 0 ? @player_one : @player_two
    tiles_opponent_can_reach = get_all_the_reachable_places(player)
    left_side = locations[0].all? {|location| !tiles_opponent_can_reach.include?(location)}
    right_side = locations[1].all? {|location| !tiles_opponent_can_reach.include?(location)}
    [left_side, right_side]
  end

  def get_all_the_reachable_places(player)
    opponent = @winchcker.opponent_player(player)
    tiles_can_reach  = []
    opponent.pieces.each do |piece|
      tiles_can_reach += piece.get_movable_positions(@board)
    end
    tiles_can_reach
  end

  def empty_space_check(rooks, player)

    locations = player.player_number == 0 ? @player_one : @player_two
    left_side = locations[0].all? {|location| @board_with_object[location[0]][location[1]].nil? }
    right_side = locations[1].all? {|location| @board_with_object[location[0]][location[1]].nil? }
    [left_side, right_side]

  end

  def rook_move_check(chosen_piece)
    all_of_rooks_places = [[[7,7],[7,0]],[[0,7],[0,0]]]
    current_player_rooks = all_of_rooks_places[chosen_piece.player_number]
    [check_rooks(current_player_rooks[0]), check_rooks(current_player_rooks[1])]

  end

  def check_rooks(location) 
    piece =  @board.board_with_object[location[0]][location[1]]
    if piece.nil?
      false
    elsif piece.piece_type == 'ro' && piece.number_of_moves == 0
      true
    end
  end
end