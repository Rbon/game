## TODO:
## "The connected region is now part of the main one. Unify it."

class Generator
  def initialize(opts)
    @grid = Grid.new(opts[:grid_length], opts[:grid_height])
    puts opts[:prng].inspect
    @area_gen = AreaGen.new(
      prng: opts[:prng],
      grid_length: opts[:grid_length],
      grid_height: opts[:grid_height],
      min_length: opts[:min_room_length],
      max_length: opts[:max_room_length],
      min_height: opts[:min_room_height],
      max_height: opts[:max_room_height]
    )
    @drawer = Drawer.new
    @populator = Populator.new(area_gen: @area_gen)
  end

  def generate
    room_list = []
    puts "GRID LENGTH #{@grid.length}"
    puts "GRID HEIGHT #{@grid.height}"
    puts
    area = @area_gen.run
    @grid.set(:room, *area)
    puts @drawer.draw(@grid)
  end
end

class Drawer
  def draw(grid)
    output = ""
    x_max = grid.length - 1
    y_max = grid[0].length - 1
    for y in 0..y_max
      for x in 0..x_max
        case grid[x][y].label
        when :empty
          output << "-"
        when :room
          output << "0"
        when :corridor
          output << "O"
        when :door
          output << "."
        when :debug, :connector
          output << "x"
        else
          output << "?"
        end
        if x == x_max
          output << "\n"
        end
      end
    end
    return output
  end
end

class Cell
  attr_reader :pos
  attr_accessor :label

  def initialize(opts = {})
    @label = opts[:label] || :empty
    @pos = opts[:pos]
  end
end

class Grid
  attr_reader :length, :height
  attr_accessor :grid

  def initialize(x, y)
    @length = x - 1
    @height = y - 1
    # @grid = Array.new(x) { Array.new(y) { Cell.new(label: :empty) } }
    @grid = []
    x.times do |x_pos|
      col = []
      y.times do |y_pos|
        cell = Cell.new(pos: [x_pos, y_pos])
        col << cell
      end
      @grid << col
    end
  end

  def [](key)
    @grid[key]
  end

  def set(label, x, y, length=1, height=1)
    puts "SETTING WITH THESE COORDS"
    puts "x: #{x}"
    puts "y: #{y}"
    puts "length: #{length}"
    puts "height: #{height}"
    puts
    pile = []
    rows = @grid[x..(x+length-1)]
    rows.each do |row|
      cells = row[y..(y+height-1)]
      pile << cells
    end
    pile.flatten.map { |cell| cell.label = label }
  end
end

class AreaGen
  def initialize(opts)
    @prng = opts[:prng]
    @grid_length = opts[:grid_length]
    @grid_height = opts[:grid_height]
    @min_length = opts[:min_length]
    @max_length = opts[:max_length]
    @min_height = opts[:min_height]
    @max_height = opts[:max_height]
  end

  def run
    x = @prng.rand(0..@grid_length - 1)
    y = @prng.rand(0..@grid_height - 1)
    length = @prng.rand(@min_length..@max_length)
    length = [length, (@grid_length - x - 1)].min
    height = @prng.rand(@min_height..@max_height)
    height = [height, (@grid_height - y - 1)].min
    puts "GENERATED THESE COORDS"
    puts "x: #{x}"
    puts "y: #{y}"
    puts "length: #{length}"
    puts "height: #{height}"
    puts
    [x, y, length, height]
  end
end

class Populator
  def initialize(opts)
    @area_gen = opts[:area_gen]
  end

  def populate(room_list, grid)
    2.times do
      area = @area_gen.run
      puts area.inspect
      grid.set(:room, *area)
    end
  end
end

gen = Generator.new(
  prng: Random.new,
  grid_length: 63,
  grid_height: 31,
  min_room_length: 5,
  max_room_length: 25,
  min_room_height: 5,
  max_room_height: 11
) # args need to be odd numbers
gen.generate
