class EnPassant
  def initialize(board)
    @board = board
  end

  def en_passant_check_after_pawn_move(chosen_piece, location)
    player = chosen_piece.player_number == 1 ? "\e[33mplayer 1\e[0m" : "\e[32mplayer 2\e[0m"

    offset = chosen_piece.player_number == 0 ? 1 : -1
    behind_position = [location[0] + offset, location[1]]
    pawn = @board.board_with_object[behind_position[0]][behind_position[1]]
    return if pawn.nil?
    unless chosen_piece.can_en_passant == true && pawn.piece_type == 'pa' && pawn&.can_get_en_passant == true && pawn&.player_number != chosen_piece.player_number
      return
    end

    @board.last_four_moves[-1][1] = ["and captured #{player}'s \e[34m#{pawn.class}\e[0m with en_passant"]

    pawn.dead = true
  end

  def en_passant_positions(chosen_piece)
    player_number = chosen_piece.player_number
    return [] unless chosen_piece.can_en_passant == true

    pawns_can_get_en_passant = check_left_right_for_pawn(chosen_piece)
    get_positions_to_en_passant(pawns_can_get_en_passant, player_number)
  end

  def update_can_get_en_passant(turn_number)
    all_pawns = get_all_pawns
    all_pawns&.each { |pawn| can_get_en_passant_check(pawn, turn_number) }
  end

  def update_can_en_passant
    all_pawns = get_all_pawns
    all_pawns&.each do |pawn|
      row = pawn.player_number == 0 ? 3 : 4

      if pawn.current_location[0] == row
        pawn.can_en_passant = true
      else
        false
      end
    end
  end

  def can_get_en_passant_check(pawn, turn_number)
    history = pawn.location_history

    if history.size == 2 && (history[0][0] - history[1][0]).abs == 2 && pawn.first_moved_turn.nil?
      pawn.can_get_en_passant = true
      pawn.first_moved_turn = turn_number
    else
      pawn.can_get_en_passant = false
    end
  end

  private

  def get_all_pawns
    pieces = @board.player_one.pieces + @board.player_two.pieces
    pieces.select { |piece| piece.piece_type == 'pa' }
  end

  def check_left_right_for_pawn(chosen_piece)
    left_right_pieces = [chosen_piece.nearby_pieces[1], chosen_piece.nearby_pieces[2]]
    left_right_pieces.select do |piece|
      piece&.piece_type == 'pa' && piece.can_get_en_passant == true && piece.player_number != chosen_piece.player_number
    end
  end

  def get_positions_to_en_passant(pawns, player_number)
    location_offset = player_number == 0 ? -1 : 1
    positions = []
    pawns.each do |pawn|
      positions << [pawn.current_location[0] + location_offset, pawn.current_location[1]] unless pawn.nil?
    end
    positions
  end
end
