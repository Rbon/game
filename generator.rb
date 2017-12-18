## TODO:
## "The connected region is now part of the main one. Unify it."

class Generator
  def initialize
    @doorifier = Doorifier.new
    @dungeon = Dungeon.new
    @grid = @dungeon.grid
    @populator =  Populator.new
    @snaker = Snaker.new
    @start_point = StartPoint.new
    @undoorifier = Undoorifier.new
    @unsnaker = Unsnaker.new
  end

  def generate(prng, x, y, min_len, max_len, mid_wid, max_wid)
    room_list = []
    grid = @grid.new(x, y).grid
    @populator.populate(
      prng, room_list, grid, min_len, max_len, mid_wid, max_wid
    )

    coords = @start_point.find(grid, :empty)
    while coords
      @snaker.snake(prng, grid, coords[0], coords[1])
      coords = @start_point.find(grid, :empty)
    end

    @doorifier.doorify(grid)
    @undoorifier.undoorify(prng, grid, room_list)
    @unsnaker.unsnake(grid)
    grid
  end
end

class Checker
  def check(grid, x, y, len, wid)
    x = [x, 0].max
    y = [y, 0].max
    x.upto(x + len) do |col|
      if grid[col]
        y.upto(y + len) do |row|
          if grid[col][row] == :room
            return true
          end
        end
      end
    end
    return false
  end
end

class DeadEnd
  def dead_end?(grid, x, y)
    if grid[x]
      if grid[x][y] == :corridor
        neighbor_list = GetNeighbors.new.get_neighbors(grid, x, y)
        empty_neighbors = 0
        for neighbor in neighbor_list
          case neighbor
          when :empty, nil
            empty_neighbors += 1
          end
        end
        if empty_neighbors > 2
          return true
        end
      end
    end
    return false
  end
end

class DoorGetter
  def get_doors(grid, room)
    output = []
    for col in room[:left]..room[:right]
      if grid[col][room[:top]-1] == :connector
        output.push([col, room[:top]-1])
        # grid[col][room[:top]-1] = :debug
      end
      if grid[col][room[:bottom]+1] == :connector
        output.push([col, room[:bottom]+1])
        # grid[col][room[:bottom]+1] = :debug
      end
    end
    for row in room[:top]..room[:bottom]
      if grid[room[:left]-1]
        if grid[room[:left]-1][row] == :connector
          output.push([room[:left]-1, row])
          # grid[room[:left]-1][row] = :debug
        end
      end
      if grid[room[:right]+1]
        if grid[room[:right]+1][row] == :connector
          output.push([room[:right]+1, row])
          # grid[room[:right]+1][row] = :debug
        end
      end
    end
    return output
  end
end

class Doorifier
  def doorify(grid)
    x = -1
    for col in grid
      x += 1
      y = -1
      for cell in col
        y += 1
        if cell == :empty
          neighbors = GetNeighbors.new.get_neighbors(grid, x, y)
          room_connection = false
          connections = 0
          for item in neighbors
            case item
            when :room
              room_connection = true
              connections += 1
            when :corridor
              connections += 1
            end
          end
          if connections == 2 and room_connection == true
            grid[x][y] = :connector
          end
        end
      end
    end
  end
end

class Drawer
  def draw(grid)
    output = ""
    x_max = grid.length - 1
    y_max = grid[0].length - 1
    for y in 0..y_max
      for x in 0..x_max
        case grid[x][y]
        when :empty
          output << " "
        when :room
          output << "0"
        when :corridor
          output << "O"
        when :door
          output << "."
        when :debug, :connector
          output << "x"
        end
        if x == x_max
          output << "\n"
        end
      end
    end
    return output
  end
end

class Dungeon
  def initialize(opts = {})

  end
end

class Filler
  def fill(grid, x, y, len=0, wid=0)
    x.upto(x + len) { |col| grid[col].fill(:room, y..y+wid) }
  end
end

class FirstDeadEnd
  def find(grid)
    x = 0
    for col in grid
      y = 0
      for row in col
        if DeadEnd.new.dead_end?(grid, x, y)
          return x, y
        end
        y += 1
      end
      x += 1
    end
  return false
  end
end

class GetNeighbors
  def get_neighbors(grid, x, y)
    output = [nil, nil, nil, nil]
    output[0] = grid[x-1][y] if x > 0
    output[1] = grid[x+1][y] if x < grid.length-1
    output[2] = grid[x][y-1] if y > 0
    output[3] = grid[x][y+1] if y < grid.length-1
    output
  end
end

class Grid
  attr_accessor :grid

  def initialize(x, y)
    @grid = Array.new(x) { Array.new(y) { :empty } }
  end
end

class Populator
  def populate(prng, room_list, grid, min_len, max_len, min_wid, max_wid)
    x_max = grid.length - 1
    y_max = grid[0].length - 1
    fails = 0

    until fails == 100
      x = prng.rand(1 .. x_max / 2) * 2 - 1
      y = prng.rand(1 .. y_max / 2) * 2 - 1
      len = prng.rand((min_len - 1) / 2 .. (max_len - 1) / 2) * 2
      wid = prng.rand((min_wid - 1) / 2 .. (max_wid - 1) / 2) * 2

      if x+len > x_max or y+len > y_max
        fails += 1
      elsif Checker.new.check(grid, x, y, len, wid)
        fails += 1
      else
        Filler.new.fill(grid, x, y, len, wid)
        room_list.push(Roomer.new.room(x, y, len, wid))
        fails = 0
      end
    end
  end
end

class Roomer
  def room(x, y, len, wid)
    {:left => x, :top => y, :right => x+len, :bottom => y+wid}
  end
end

class Snaker
  def snake(prng, grid, x, y)
    if x < 0
      return false
    elsif y < 0
      return false
    end
    if grid[x]
      if grid[x][y] == :empty
        grid[x][y] = :corridor
        order = [1,2,3,4].shuffle!(random: prng)
        for n in order
          case n
          when 1
            if snake(prng, grid, x+2, y)
              grid[x+1][y] = :corridor
            end
          when 2
            if snake(prng, grid, x-2, y)
              grid[x-1][y] = :corridor
            end
          when 3
            if snake(prng, grid, x, y+2)
              grid[x][y+1] = :corridor
            end
            if snake(prng, grid, x, y-2)
              grid[x][y-1] = :corridor
            end
          end
        end
        return true
      end
    end
  end
end

class StartPoint
  def find(grid, target)
    x = 1
    y = 1
    while y < grid[0].length
      if grid[x]
        if grid[x][y] == target
          return x, y
        end
        x += 2
      else
        x = 1
        y += 2
      end
    end
    return false
  end
end

class Undoorifier
  def undoorify(prng, grid, room_list)
    for room in room_list
      door_list = DoorGetter.new.get_doors(grid, room).shuffle!(random: prng)
      first_door = door_list.pop
      grid[first_door[0]][first_door[1]] = :door
      for door in door_list
        case prng.rand(1..50)
        when 1..49
          grid[door[0]][door[1]] = :empty
        else
          grid[door[0]][door[1]] = :door
        end
      end
    end
  end
end

class Unsnaker
  def unsnake(grid, coords=nil)
    if coords
      x = coords[0]
      y = coords[1]
      if DeadEnd.new.dead_end?(grid, x, y)
        grid[x][y] = :empty
        followups = 0
        followups += unsnake(grid, [x+1, y])
        followups += unsnake(grid, [x-1, y])
        followups += unsnake(grid, [x, y+1])
        followups += unsnake(grid, [x, y-1])
        if followups == 0
          unsnake(grid)
        end
        return 1
      end
    else
      start = FirstDeadEnd.new.find(grid)
      if start
        unsnake(grid, start)
      end
    end
    return 0
  end
end

thing = Generator.new.generate(Random.new, 64, 32, 5, 25, 5, 11) # args need to be odd numbers

puts Drawer.new.draw(thing)
