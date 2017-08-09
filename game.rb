require_relative 'board.rb'
require_relative 'display.rb'
require_relative 'cursor.rb'
require_relative "player.rb"
require 'byebug'

class Game
  attr_reader :current_player, :board
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
      @display.message = "Check!" if king_in_check?
      get_move
      @display.message = ""
      change_player
    end
  end

  def get_move
    puts @current_player.color
    begin
      loop do
        start_pos, end_pos = @current_player.get_input
        @board.move_piece(start_pos, end_pos)
        break unless king_in_check?
        @display.message = "Your king is in check!"
        @board.unmove_piece(end_pos, start_pos)
      end
    rescue WrongColorError
      @display.message = "That's not your piece!"
      retry
    rescue InvalidMoveError
      @display.message = "Enter a valid move"
      retry
    # ensure
    #   @display.clear_and_render
    end
  end

  def over?
    false
  end



  def king_in_check?
    all_pieces = @board.grid.flatten
    king = all_pieces.select do |piece|
      piece.is_a?(King) && piece.color == @current_player.color
    end.last
    opponents = all_pieces.select do |piece|
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
