class Player
  attr_accessor :name, :color, :display
  def initialize (name = nil)
    @name = name
    @color = nil
  end
end

class HumanPlayer < Player
  def get_input
    @display.clear_and_render
    start_pos = get_start_pos
    end_pos = get_end_pos
    [start_pos, end_pos]
  end

  def get_start_pos
    until @display.cursor.selected
      @display.cursor.get_input
      @display.clear_and_render
    end
    pos = @display.cursor_pos.reverse
    if @display.grid[pos.first][pos.last].color != @color
      @display.cursor.selected = false
      raise WrongColorError.new "That's not your piece!"
    end
    @display.clear_and_render
    @display.cursor_pos.reverse
  end

  def get_end_pos
    while @display.cursor.selected
      @display.cursor.get_input
      @display.clear_and_render
    end
    @display.clear_and_render
    @display.cursor_pos.reverse
  end
end

class ComputerPlayer < Player

end

class WrongColorError < StandardError
end
