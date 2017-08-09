require_relative 'board.rb'
require_relative 'display.rb'
require_relative 'cursor.rb'
require_relative "player.rb"
require 'byebug'

class Game
  attr_reader :current_player, :board, :all_pieces
  def initialize
    @board = Board.new
    @display = Display.new(@board)
    players = create_players
    @player1 = players.first
    @player2 = players.last
    @player1.display = @display
    @player2.display = @display
    @current_player = @player1
    @player1.color = :white
    @player2.color = :black
    @all_pieces = @board.grid.flatten
  end

  def get_num_human_players
    puts "How many human players? (0-2)"
    begin
      num_human_players = Integer(gets.chomp)
      unless (0..2).cover?(num_human_players)
        raise ArgumentError
      end
    rescue ArgumentError
      puts "Please enter a number from 0-2"
      retry
    end
    num_human_players
  end

  def create_players
    num = get_num_human_players
    human_names = []
    1.upto(num) do |idx|
      puts "Player #{idx}, what's your name?"
      human_names << gets.chomp
    end
    players = []
    human_names.each do |name|
      players << HumanPlayer.new(name)
    end
    (2-players.length).times do
      players << ComputerPlayer.new("Robot Overlord")
    end
    players
  end



  def play
    until over?
      @display.message = "#{@current_player.color}, it's your turn - your king is in Check!" if king_in_check?
      get_move
      change_player
      @display.message = "#{@current_player.color}, it's your turn!"
    end
  end

  def get_move
    puts @current_player.color
    begin
      loop do
        start_pos, end_pos = @current_player.get_input
        @board.move_piece(start_pos, end_pos)
        distance_moved = diff(start_pos, end_pos)
        if @board[end_pos].is_a?(King) && distance_moved == 2
          complete_castle(distance_moved)
        end
        break unless king_in_check?
        @display.message = "#{@current_player.color}, your king is in check!"
        @board.force_move_piece(end_pos, start_pos)
      end
      update_castle_eligibility
    rescue WrongColorError
      @display.message = "#{@current_player.color}, that's not your piece!"
      retry
    rescue InvalidMoveError
      @display.message = "#{@current_player.color}, enter a valid move"
      retry
    end
  end

  def diff(start_pos, end_pos)
    x1,y1 = start_pos
    x2,y2 = end_pos
    ((x2-x1)**2 + (y2-y1)**2)**0.5
  end

  def complete_castle(distance_moved)
    row = (@current_player.color == :white ? 7 : 0)
    king_pos = get_king.pos

    if distance_moved > 0
      @board.force_move_piece([7,row],[king_pos.first-1,row])
    else
      @board.force_move_piece([0,row],[king_pos.first+1,row])
    end
  end

  def get_king
    @all_pieces.select do |piece|
      piece.is_a?(King) && piece.color == @current_player.color
    end.last
  end

  def update_castle_eligibility
    row = @current_player.color == :white ? 7 : 0
    king = get_king
    king.has_moved = true if king.pos!=[4,row]
    # debuggerg
    rooks = @all_pieces.select do |piece|
      piece.is_a?(Rook) && piece.color == @current_player.color
    end
    rooks.each { |rook| rook.has_moved = true unless rook.pos==[0,row] || rook.pos==[7,row] }
  end

  def over?
    false
  end

  def king_in_check?
    king = get_king
    opponents = @all_pieces.select do |piece|
      !piece.is_a?(NullPiece) && piece.color != @current_player.color
    end
    opponents.any? do |piece|
      @board.valid_move?(piece.pos, king.pos)
    end
  end

  def change_player
    if @current_player == @player1
      @current_player = @player2
    else
      @current_player = @player1
    end
  end
end
