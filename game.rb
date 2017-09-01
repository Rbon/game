require "./entities.rb"
require 'curses'

class Main
  def initialize
    Curses.curs_set(0) # Invisible cursor
    Curses.noecho # Don't display pressed characters
    @width = 80
    @height = 32
    @layer_0 = TestFloor.new.floor(width: @width - 2, height: @height - 2)
    @layer_1 = Grid.new(width: @width - 2, height: @height - 2)
    @layer_1.grid[2][3] = "@"
    @main_window = Window.new(height: 34, width: 80, border: MainBorder)
    @dialog_window = DialogWindow.new(
      top: 33,
      height: 12,
      width: 80,
      border: DialogBorder
    )
  end

  def run
    loop do
      puts
      print " > "
      line = @grammar.parse(line: gets.strip.chomp)
      line[:actor] = @player
      @player.act(line)
    end
  end

  def test
    begin
      Curses.init_screen
      @dialog_window.print(text: "foo")
      @main_window.refresh
      gets
    ensure
      Curses.close_screen
    end
  end
end

class DialogBuffer
  def initialize
    @buffer = []
  end

  def add(args)
    @buffer << args[:text].split("\n")
  end

  def text
    diff = [10 - @buffer.length, 0].max
    padding = Array.new(diff) { nil }
    (@buffer + padding).flatten.reverse[0..9].join("\n")
  end
end

class Window
  def initialize(opts)
    @height = opts[:height]
    @width = opts[:width]
    @top = opts[:top] || 0
    @left = opts[:left] || 0
    @window = Curses::Window.new(@height, @width, @top, @left)
    @border = (opts[:border] || Border).new(width: @width, height: @height).text
    @window.keypad = true
    @layer_list = []
    refresh
  end

  def draw(args)
    top = args[:top] || 1
    left = args[:left] || 1
    line_list = args[:text].split("\n")
    line_list.each do |line|
      @window.setpos(top, left)
      @window.addstr(line)
      top += 1
    end
  end

  def refresh
    draw(top: 0, left: 0, text: @border)
    @layer_list.each { |layer| draw(text: layer.text) }
    @window.refresh
  end
end

class DialogWindow < Window
  def initialize(opts)
    super
    @buffer = DialogBuffer.new
  end

  def print(args)
    @buffer.add(args)
    draw(top: 0, left: 0, text: @border)
    draw(text: @buffer.text)
    @window.refresh
  end
end

class Border
  def initialize(opts)
    @width = opts[:width]
    @height = opts[:height]
    @vert = opts[:vert] || "\u2502"
    @left = opts[:left] || @vert
    @right = opts[:right] || @vert
    @hor = opts[:hor] || "\u2500"
    @top = opts[:top] || @hor
    @bottom = opts[:bottom] || @hor
    @ul_corner = opts[:ul_corner] || "\u250C"
    @ur_corner = opts[:ur_corner] || "\u2510"
    @bl_corner = opts[:bl_corner] || "\u2514"
    @br_corner = opts[:br_corner] || "\u2518"
  end

  def text
    output = line(left: @ul_corner, middle: @top, right: @ur_corner)
    (@height -2).times { output << line(left: @left, right: @right) }
    output + line(left: @bl_corner, middle: @bottom, right: @br_corner)
  end

  def line(args)
    middle = args[:middle] || " "
    args[:left] + (middle * (@width - 2)) + args[:right]
  end
end

class MainBorder < Border
  def initialize(opts)
    super
    @bottom = "\u2550"
    @bl_corner = "\u255E"
    @br_corner = "\u2561"
  end
end

class DialogBorder < Border
  def initialize(opts)
    super
    @top = "\u2550"
    @ul_corner = "\u255E"
    @ur_corner = "\u2561"
  end
end

class Grid
  attr_accessor :grid

  def initialize(opts)
    @width = opts[:width]
    @height = opts[:height]
    @grid = Array.new(@height) { Array.new(@width) { [] } }
  end

  def text
    (@grid.map { |line| line.join("") }).join("\n")
  end
end

class TestFloor
  def floor(args)
    output = ""
    args[:height].times do
      output << "." * args[:width]
      output << "\n"
    end
    output
  end
end

class Grammar
  def initialize
    @preposition_list = ["on", "in", "with", "from"]
  end

  def parse(args)
    output = {}
    target = []
    line = args[:line].split
    output[:action] = line.shift.to_sym
    output[:prep] = nil
    line.count.times do
      word = line.shift
      if @preposition_list.include?(word)
        output[:prep] = word
        break
      else
        target.push(word)
      end
    end
    target = target.join(" ")
    tool = line.join(" ")
    output[:target] = (target.empty? ? nil : target)
    output[:tool] = (tool.empty? ? nil : tool)
    output
  end
end

Main.new.test
