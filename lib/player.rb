require_relative 'chess_piece.rb'

class Player

  attr_accessor :pieces, :name, :dead_pieces, :check, :checkmate, :player_number, :flag
  def initialize(name, player_number)
    @name = name
    # @board = board
    @player_number = player_number
    @pieces = []
    @dead_pieces =[]
    @check = false
    @checkmate = false
    # test_board_setup(player_number)
    @flag = false
    setup_initial_pieces(player_number)
  end


  def test_board_setup(player_number)
    # if player_number == 0 
    #   @pieces << instance_variable_set("@pawn1", Pawn.new(@player_number, 'p', [4, 4]))
    # else
    #   @pieces << instance_variable_set("@pawn2", Pawn.new(@player_number, 'p', [3, 5]))
    #   @pieces << instance_variable_set("@pawn3", Pawn.new(@player_number, 'p', [0, 5]))

    # end
    # if player_number == 0 
    #   @pieces << instance_variable_set("@pawn1", Knight.new(@player_number, 'n', [4, 4]))
    #   @pieces << instance_variable_set("@pawn5", Rook.new(@player_number, 'b', [4, 3]))
    #   @pieces << instance_variable_set("@pawn5", Rook.new(@player_number, 'b', [3, 3]))

    # else
    #   @pieces << instance_variable_set("@pawn2", Bishop.new(@player_number, 'b', [3, 5]))
    #   # @pieces << instance_variable_set("@pawn3", Pawn.new(@player_number, 'p', [0, 5]))
    # end

    if player_number == 0 
      @pieces << instance_variable_set("@pawn1", King.new(@player_number, 'ki', [4, 4]))
      @pieces << instance_variable_set("@pawn5", Rook.new(@player_number, 'ro', [3, 2]))
      @pieces << instance_variable_set("@pawn4", Queen.new(@player_number, 'qu', [0, 6]))

    else
      @pieces << instance_variable_set("@pawn2", King.new(@player_number, 'ki', [1, 1]))
      # @pieces << instance_variable_set("@pawn3", Pawn.new(@player_number, 'pa', [0, 2]))
    end
  end

  def setup_initial_pieces(player_number)
    setup_pawns(player_number)
    setup_rest_of_pieces(player_number)
  end

  def setup_pawns(player_number)
    row = player_number == 0 ? 6 : 1
    8.times do |num|
      #
      @pieces << instance_variable_set("@pawn#{num}", Pawn.new(@player_number, 'pa', [row, num]))

      # @pieces << instance_variable_set("@pawn#{num}", ChessPiece.new(@player_number, 'p', [row, num]))
    end
  end

  def setup_rest_of_pieces(player_number)
    row = player_number == 0 ? 7 : 0
    # set_up_layout = ['r','n','b','k','q','b','n','r']
    layout = {rook_one:'ro',kinght_one:'kn',bishop_one:'bi',queen:'qu',king:'ki',bishop_two:'bi',kight_two:'kn',rook_two:'ro'}
    class_match = {'ro'=> Rook, 'kn' => Knight, 'bi' => Bishop, 'ki' => King, 'qu' => Queen}
    layout.each_with_index do |(key,value),index| 
      @pieces << instance_variable_set("@#{key.to_s}", class_match[value].new(@player_number,value,[row,index]))
    end
  end
  ### knight need to match 'n'
  def get_positions_of_pieces(type)
    pieces = []
    @pieces.each do |piece|
      pieces << piece if piece.piece_type == type
    end
    pieces
  end

  #updates @nearby_pieces of each piece
  def update_nearby_chesspieces_for_all_pieces(board)
    @pieces.each {|piece| piece.update_nearby_chesspieces(board)}
  end

  def check_for_dead_pieces
    @pieces.each do |piece|
      @dead_pieces << @pieces.delete(piece) if piece.dead
    end
  end

  def get_pieces_has_movable_places(board)
    pieces_can_move = @pieces.select do |piece|
      piece.get_movable_positions(board).size > 1
    end
    pieces_can_move
  end
end