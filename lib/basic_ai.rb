require_relative 'player.rb'

class BasicAi < Player
  
  def initialize(name, player_number,board,chess_board)
    super(name, player_number, board,chess_board)
    @all_the_possible_moves = []
  end


  def get_all_possible_moves_of_all_pieces
    @all_the_possible_moves.clear
    @pieces.each do |piece|
      piece_moves = piece.get_movable_positions(@board)
      next if piece_moves.size <= 1
      piece_moves[1..-1].each {|move| @all_the_possible_moves << [piece, move] unless @chess_game.illegal_move.illegal_move_checker(piece, move)}
    end
  end

  def pick_one_move
    ai_thinking_message
    get_all_possible_moves_of_all_pieces
    num_of_moves = @all_the_possible_moves.size - 1
    @chess_game.winchecker.checkmate_check(self) if num_of_moves <= 0
    random_number = rand(0..num_of_moves)
    random_move = @all_the_possible_moves[random_number]
  end

  def ai_thinking_message
    puts "\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    puts "Basic Ai is thinking........".rjust(10)
    puts "🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    # sleep(2)
  end

  

end