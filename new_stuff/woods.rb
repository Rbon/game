## NOTES:
## Doot. A door that, instead of opening, goes "doot".

require 'curses'
require './generator'


class World
  attr_reader :ent_list, :floor

  def initialize
    @ent_list = []
    @floor = "................................................................
................................................................
................................................................
................................................................
................................................................
..........................|.....................................
..........................|.....................................
..........................|.....................................
..........................|.....................................
..........................|.....................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................"
  end
end


class Game
  def initialize
    @world = World.new
    @floor = Generator.field(64, 32)
    @player = Player.new(@world, 1, 1)
  end

  def main
    begin
      Curses.init_screen
      Curses.curs_set(0) # Invisible cursor
      Curses.noecho # Don't display pressed characters
      win1 = Curses::Window.new(34, 66, 0, 0)
      win1.box("|", "-")
      win1.keypad=(true)
      draw(win1, @floor)
      @running = true

      while @running
        manage_input(win1.getch)
        draw(win1, @floor)
      end

    ensure
      Curses.close_screen
    end
  end

  def draw(win, grid)
    floor = ""
    x_max = grid.length - 1
    y_max = grid[0].length - 1
    for y in 0..y_max
      for x in 0..x_max
        if grid[x][y]
          floor << "O"
        else
          floor << "."
        end
        if x == x_max
          floor << "\n"
        end
      end
    end

    floor.chomp!
    curs_y = 1
    win.setpos(curs_y, 1)
    for row in floor.split("\n")
      win.addstr(row)
      curs_y = curs_y + 1
      win.setpos(curs_y, 1)
    end

    for entity in @world.ent_list
      win.setpos(entity.y_pos, entity.x_pos)
      win.addstr(entity.char)
    end

    win.refresh
  end

  def manage_input(input)
    case input
    when "l", Curses::Key::RIGHT
      @player.move("right")
    when "h", Curses::Key::LEFT
      @player.move("left")
    when "k", Curses::Key::UP
      @player.move("up")
    when "j", Curses::Key::DOWN
      @player.move("down")
    when "q"
      @running = false
    end
  end

  def dev_output(string, win)
    win.setpos(33, 0)
    win.addstr(string+"   ")
  end
end


class Player
  attr_reader :char, :x_pos, :y_pos, :spawn, :move

  def initialize(world, y_pos, x_pos)
    @world = world
    @x_pos = x_pos
    @y_pos = y_pos
    @char = "@"
    @world.ent_list.push(self)
  end

  def move(direction)
    case direction
    when "up"
      @y_pos -= 1
    when "down"
      @y_pos += 1
    when "left"
      @x_pos -= 1
    when "right"
      @x_pos += 1
    end
  end
end


Game.new.main
