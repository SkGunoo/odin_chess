class GoodAi < Player
  
  def initialize(name, player_number,board,chess_game)
    super(name, player_number, board,chess_game)
    @all_the_possible_moves = []
    @score_sheet = {Knight: 3, Rook: 5, Queen: 9, Bishop: 3, Pawn: 1, king: 1}
  end


  def pick_one_move
    ai_thinking_message
    @all_the_possible_moves.clear

    get_all_possible_moves_of_all_pieces(@pieces, @all_the_possible_moves)
    scored_moves = score_moves_with_points.sort_by {|moves| -moves[2]}
    
    if scored_moves[0][2] == 10
      picked_move = scored_moves[0]
      picked_move_without_socre = picked_move[0..1]
    else
      highest_socre = scored_moves[0][2]
      high_scored_moves = scored_moves.select {|move| move[2] == highest_socre}
      random_number = high_scored_moves.size - 1
      picked_move =  high_scored_moves[random_number]
      picked_move_without_socre = picked_move[0..1]
      
    end
    
  end

  def get_all_possible_moves_of_all_pieces(pieces, moves =[])
    pieces.each do |piece|
      piece_moves = piece.get_movable_positions(@board)
      next if piece_moves.size < 2
      piece_moves[1..-1].each {|move| moves << [piece, move] unless @chess_game.illegal_move.illegal_move_checker(piece, move)}
    end
    moves
  end

  def score_moves_with_points
    opponent = @chess_game.winchecker.opponent_player(self)
    opponent_moves = get_all_possible_moves_of_all_pieces(opponent.pieces)
    tiles_opponent_can_reach = opponent_moves.map {|move| move[1]}
    opponent_king_location = @chess_game.winchecker.get_king_location(opponent)
    scored_moves = score_moves_with_points_part_two(tiles_opponent_can_reach, opponent_king_location)
    
  end

  def score_moves_with_points_part_two(opponent_tiles, opponent_king_location)
    @all_the_possible_moves.map do |move|
      score = 0
      piece = move[0]
      location = move[1]
      tile_content = @board.board_with_object[location[0]][location[1]]
      score += 2 if piece.piece_type == "pa" && piece.num_of_moves > 1
      score -= @score_sheet[class_to_sym(piece)] if opponent_tiles.include?(location)
      score += @score_sheet[class_to_sym(tile_content)] unless tile_content.nil?
      score += 10 if can_catch_king_next_move?(piece, location, opponent_king_location) && !opponent_tiles.include?(location)
      [piece, location, score]
    end
  end

  def can_catch_king_next_move?(chosen_piece, location,opponent_king_location)
    board_copy = Marshal.load(Marshal.dump(@board))
    copied_chosen_piece = @chess_game.illegal_move.find_the_same_piece_from_copy(chosen_piece, board_copy)
    board_copy.move_piece_for_testing(copied_chosen_piece, location)
    # current_player = board_copy.players[chosen_piece.player_number]
    board_copy.update_board
    next_movable_place = copied_chosen_piece.get_movable_positions(board_copy)
    next_movable_place.include?(opponent_king_location)
  end

  def dont_get_kill_by_king(board,ch)
    
  end

  def class_to_sym(chess_piece)
    chess_piece.class.to_s.to_sym
  end


  def ai_thinking_message
    puts "\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    puts "Good Ai is thinking........".rjust(10)
    puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    # sleep(2)
  end


end


