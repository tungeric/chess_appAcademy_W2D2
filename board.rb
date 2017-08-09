require_relative 'piece.rb'
require 'byebug'
class Board
  attr_reader :grid, :cursor_pos
  def initialize
    @null_piece = NullPiece.new(nil, nil)
    @grid = Array.new(8) { Array.new(8) { @null_piece }}
    @cursor_pos = [3,3]
    set_pieces
  end

  def move_piece(start_pos, end_pos)
    if valid_move?(start_pos, end_pos)
      self[end_pos] = self[start_pos]
      self[end_pos].pos = end_pos
      self[start_pos] = @null_piece
    else
      raise InvalidMoveError.new "invalid move"
    end
  end

  def unmove_piece(start_pos, end_pos)
    self[end_pos] = self[start_pos]
    self[end_pos].pos = end_pos
    self[start_pos] = @null_piece
  end

  def valid_move?(start_pos, end_pos)
    piece_exists = self[start_pos] != @null_piece
    empty_dest = self[end_pos] == @null_piece
    not_cannibals = self[start_pos].color != self[end_pos].color
    possible_move = possible_moves(start_pos).include?(end_pos)
    possible_move && piece_exists && (empty_dest || not_cannibals)
  end

  def possible_moves(pos)
    x,y = pos
    piece = self[pos]
    if piece.is_a?(StepPiece)
      possible_steps(piece, pos)
    elsif piece.is_a?(SlidePiece)
      possible_slides(piece, pos)
    elsif piece.is_a?(Pawn)
      possible_pawn_moves(pos)
    else
      []
    end
  end

  def possible_slides(piece, pos)
    new_moves = []
    rel_coords = piece.class::RELATIVE_CORDS
    rel_coords.each do |cord|
      x,y = pos.dup
      # debugger
      x += cord[0]
      y += cord[1]
      while (0..7).cover?(y) && (0..7).cover?(x)
        new_moves << [x,y]
        break if blocked?([x,y])
        x += cord[0]
        y += cord[1]
      end
    end
    new_moves
  end

  def possible_pawn_moves(pos)
    new_moves = []
    piece = self[pos]
    passive_moves = possible_passive_pawn_moves(pos,piece.color)
    passive_moves.select { |move| (0..7).cover?(move[1]) }
    violent_moves = possible_violent_pawn_moves(pos, piece.color)
    new_moves.concat(passive_moves).concat(violent_moves)
  end

  def possible_passive_pawn_moves(pos, color)
    direction = (color == :black ? 1 : -1)
    x, y = pos
    new_moves = []
    unless blocked?([x,y + direction])
      new_moves << [x,y + direction]
      if (color == :black && pos[1]== 1 || color == :white && pos[1] == 6)
        unless blocked?([x,y + direction*2])
          new_moves << [x,y+direction*2]
        end
      end
    end
    new_moves
  end

  def possible_violent_pawn_moves(pos, color)
    direction = (color == :black ? 1 : -1)
    x, y = pos
    attack_positions = [[x-1,y + direction], [x+1, y + direction]]
    opposite_color = (color == :white ? :black : :white)
    attack_positions.select do |attack_pos|
      # debugger
      in_range = (0..7).cover?(attack_pos.first) && (0..7).cover?(attack_pos.last)
      in_range && self[attack_pos].color == opposite_color
    end
  end

  def possible_steps(piece, pos)
    new_moves = []
    x,y = pos
    piece.class::RELATIVE_CORDS.each do |cord|
      if (0..7).cover?(y+ cord[1]) && (0..7).cover?(x + cord[0])
        new_moves << [x+cord[0], y+cord[1]]
      end
    end
    new_moves
  end

  def blocked? (pos)
    self[pos] != @null_piece
  end

  def set_pieces
    @grid[0].each_with_index do |elem, idx|
      @grid[idx][1] = Pawn.new(:black,[idx,1])
      @grid[idx][6] = Pawn.new(:white,[idx,1])

      case idx
      when 0
        @grid[idx][0] = Rook.new(:black, [idx,0])
        @grid[idx][7] = Rook.new(:white, [idx,7])
      when 7
        @grid[idx][0] = Rook.new(:black, [idx,0])
        @grid[idx][7] = Rook.new(:white, [idx,7])
      when 1
        @grid[idx][0] = Knight.new(:black, [idx,0])
        @grid[idx][7] = Knight.new(:white, [idx,7])
      when 6
        @grid[idx][0] = Knight.new(:black, [idx,0])
        @grid[idx][7] = Knight.new(:white, [idx,7])
      when 2
        @grid[idx][0] = Bishop.new(:black, [idx,0])
        @grid[idx][7] = Bishop.new(:white, [idx,7])
      when 5
        @grid[idx][0] = Bishop.new(:black, [idx,0])
        @grid[idx][7] = Bishop.new(:white, [idx,7])
      end
      @grid[4][0] = Queen.new(:black, [4,0])
      @grid[3][7] = Queen.new(:white, [3,7])
      @grid[3][0] = King.new(:black, [3,0])
      @grid[4][7] = King.new(:white, [4,7])
    end
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

end

class InvalidMoveError < StandardError
end
