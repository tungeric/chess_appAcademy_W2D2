require 'byebug'

class Piece
  attr_accessor :color, :pos
  def initialize(color, pos)
    @color = color
    @pos = pos
  end



end

class NullPiece < Piece
  def to_s
    ' '
  end
end

class SlidePiece < Piece
  RELATIVE_CORDS = []


end

class StepPiece < Piece
  RELATIVE_CORDS = []

end

class King < StepPiece
  RELATIVE_CORDS = [
    [-1,0],
    [-1,1],
    [0,1],
    [1,1],
    [1,0],
    [1,-1],
    [0,-1],
    [-1,-1]]
  def to_s
    @color == :white ? '♔' : '♚'
  end
end

class Queen < SlidePiece
  RELATIVE_CORDS = [
    [-1,0],
    [-1,1],
    [0,1],
    [1,1],
    [1,0],
    [1,-1],
    [0,-1],
    [-1,-1]]
  def to_s
    @color == :white ? '♕' : '♛'
  end
end


class Bishop < SlidePiece
  RELATIVE_CORDS = [
    [-1,1],
    [1,1],
    [1,-1],
    [-1,-1]]
  def to_s
    @color == :white ? '♗' : '♝'
  end
end

class Knight < StepPiece
  RELATIVE_CORDS = [
    [-1,-2],
    [1,-2],
    [2,-1],
    [2,1],
    [1,2],
    [-1,2],
    [-2,1],
    [-2,-1]
  ]
  def to_s
    @color == :white ? '♘' : '♞'
  end
end

class Rook < SlidePiece
  RELATIVE_CORDS = [
    [0,1],
    [1,0],
    [-1,0],
    [0,-1]
  ]
  def to_s
    @color == :white ? '♖' : '♜'
  end
end

class Pawn < Piece
  def to_s
    @color == :white ? '♙' : '♟'
  end
end
