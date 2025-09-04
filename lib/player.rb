require_relative 'chess_piece.rb'
class Player

  attr_accessor :pieces, :name
  def initialize(name, player_number)
    @name = name
    @player_number = player_number
    @pieces = []
    setup_initial_pieces(player_number)
    # p @pieces #delete this later
  end

  def setup_initial_pieces(player_number)
    setup_pawns(player_number)
    setup_rest_of_pieces(player_number)
  end

  def setup_pawns(player_number)
    row = player_number == 0 ? 6 : 1
    8.times do |num|
      #
      @pieces << instance_variable_set("@pawn#{num}", ChessPiece.new(@player_number, 'p', [row, num]))
    end
  end

  def setup_rest_of_pieces(player_number)
    row = player_number == 0 ? 7 : 0
    # set_up_layout = ['r','n','b','k','q','b','n','r']
    layout = {rock_one:'r',kinght_one:'n',bishop_one:'b',king:'k',queen:'q',bishop_two:'b',kight_two:'n',rock_two:'r'}
    layout.each_with_index do |(key,value),index| 
      @pieces << instance_variable_set("@#{key.to_s}", ChessPiece.new(@player_number,value,[row,index]))
    end
  end

  def get_positions_of_pieces(type)
    pieces = []
    @pieces.each {|piece|pieces << piece if piece.piece_type == type}
    pieces
  end

end