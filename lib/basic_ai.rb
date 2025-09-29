require_relative 'player'

class BasicAi < Player
  def initialize(name, player_number, board, chess_board)
    super(name, player_number, board, chess_board)
    @all_the_possible_moves = []
  end

  def get_all_possible_moves_of_all_pieces
    @all_the_possible_moves.clear
    @pieces.each do |piece|
      piece_moves = piece.get_movable_positions(@board)
      next if piece_moves.size <= 1

      piece_moves[1..-1].each do |move|
        @all_the_possible_moves << [piece, move] unless @chess_game.illegal_move.illegal_move_checker(piece, move)
      end
    end
  end

  def pick_one_move
    ai_thinking_message
    @chess_game.winchecker.checkmate_check(self) if @check
    @chess_game.winchecker.stalemate_check(self, @chess_game.turn_number)
    get_all_possible_moves_of_all_pieces
    num_of_moves = @all_the_possible_moves.size - 1
    random_number = rand(0..num_of_moves)
    @all_the_possible_moves[random_number]
  end

  private

  def ai_thinking_message
    puts "\n🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹"
    puts "#{pick_ai_thinking_messages}"
    puts '🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹🭹'
    sleep(2)
  end

  def pick_ai_thinking_messages
    messages = [
      'Dumb AI is trying to remember the rules ........',
      'Dumb AI thinks this might be checkers ........',
      'Dumb AI is counting its fingers ........',
      'Dumb AI forgot which piece does what ........',
      'Dumb AI is wondering if knights can fly ........',
      'Dumb AI is looking for the instructions ........',
      'Dumb AI thinks pawns move backwards, right? ........',
      'Dumb AI is confused about everything ........',
      'Dumb AI is trying really hard (not really) ........',
      'Dumb AI just realized this is chess ........',
      'Dumb AI is making up its own rules ........',
      'Dumb AI thinks the king is the fastest piece ........',
      'Dumb AI is second-guessing itself ........',
      'Dumb AI hopes this works ........',
      'Dumb AI has no idea what it\'s doing ........',
      'Dumb AI is winging it ........',
      'Dumb AI thinks strategy is overrated ........',
      'Dumb AI is going with gut feeling ........'
    ]
    random_number = rand((messages.size) -1)
    messages[random_number]
  end
end
