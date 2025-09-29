require_relative 'chess_piece'

class Player
  attr_accessor :pieces, :name, :dead_pieces, :check, :checkmate, :player_number, :flag, :ai

  def initialize(name, player_number, board, chess_game)
    @name = name
    @board = board
    @chess_game = chess_game
    @player_number = player_number
    @pieces = []
    @dead_pieces = []
    @check = false
    @checkmate = false
    @ai = false
    # test_board_setup(player_number)
    @flag = false
    setup_initial_pieces(player_number)
  end

  
  ### knight need to match 'n'

  def promote_pawn(chosen_piece, location)
    index = @ai == true ? 3 : chosen_piece.pick_piece(@name)
    class_match = { 'kn' => Knight, 'bi' => Bishop, 'ro' => Rook, 'qu' => Queen }

    # promotes = {Knight => 'kn', Bishop => 'bi', Rook => 'ro', Queen => 'qu'}
    # promotes = {Knight: 'kn', Bishop: 'bi', Rook: 'ro', Queen: 'qu'}
    class_type = class_match.values[index]
    piece_type = class_match.keys[index]
    chosen_piece.dead = true
    check_for_dead_pieces
    @pieces << instance_variable_set("@#{class_type}", class_type.new(@player_number, piece_type, location))
  end

  # updates @nearby_pieces of each piece
  def update_nearby_chesspieces_for_all_pieces(board)
    @pieces.each { |piece| piece.update_nearby_chesspieces(board) }
  end

  def check_for_dead_pieces
    @pieces.each do |piece|
      @dead_pieces << @pieces.delete(piece) if piece.dead
    end
  end

  # the first element of get_movable_positions(board) return is 
  # its current location, so we dont count it
  def get_pieces_has_movable_places(board)
    @pieces.select do |piece|
      piece.get_movable_positions(board).size > 1
    end
  end

  def get_positions_of_pieces(type)
    pieces = []
    @pieces.each do |piece|
      pieces << piece if piece.piece_type == type
    end
    pieces
  end

  private

  def setup_initial_pieces(player_number)
    setup_pawns(player_number)
    setup_rest_of_pieces(player_number)
  end

  def setup_pawns(player_number)
    row = player_number == 0 ? 6 : 1
    8.times do |num|
      @pieces << instance_variable_set("@pawn#{num}", Pawn.new(@player_number, 'pa', [row, num]))

      # @pieces << instance_variable_set("@pawn#{num}", ChessPiece.new(@player_number, 'p', [row, num]))
    end
  end

  def setup_rest_of_pieces(player_number)
    row = player_number == 0 ? 7 : 0
    # set_up_layout = ['r','n','b','k','q','b','n','r']
    layout = { rook_one: 'ro', kinght_one: 'kn', bishop_one: 'bi', queen: 'qu', king: 'ki', bishop_two: 'bi', kight_two: 'kn',
               rook_two: 'ro' }
    class_match = { 'ro' => Rook, 'kn' => Knight, 'bi' => Bishop, 'ki' => King, 'qu' => Queen }
    layout.each_with_index do |(key, value), index|
      @pieces << instance_variable_set("@#{key}", class_match[value].new(@player_number, value, [row, index]))
    end
  end

  

  
end
