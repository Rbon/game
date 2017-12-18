## TODO:
## "The connected region is now part of the main one. Unify it."

class Generator

  def self.floor(prng, x, y, min_len, max_len, mid_wid, max_wid)
    room_list = []
    grid1 = grid(x, y)
    populate(prng, room_list, grid1, min_len, max_len, mid_wid, max_wid)

    coords = start_point(grid1, :empty)
    while coords
      snake(prng, grid1, coords[0], coords[1])
      coords = start_point(grid1, :empty)
    end

    doorify(grid1)
    undoorify(prng, grid1, room_list)
    unsnake(grid1)
    return grid1
  end

  def self.grid(x, y)
    Array.new(x) { Array.new(y) { :empty } }
  end

  def self.populate(prng, room_list, grid, min_len, max_len, min_wid, max_wid)
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
      elsif check(grid, x, y, len, wid)
        fails += 1
      else
        fill(grid, x, y, len, wid)
        room_list.push(room(x, y, len, wid))
        fails = 0
      end
    end
  end

  def self.room(x, y, len, wid)
    return {:left => x, :top => y, :right => x+len, :bottom => y+wid}
  end

  def self.fill(grid, x, y, len=0, wid=0)
    for col in x..x+len
      grid[col].fill(:room, y..y+wid)
    end
  end

  def self.check(grid, x, y, len, wid)
    if x < 0
      x = 0
    end
    if y < 0
      y = 0
    end
    for col in x..x+len
      if grid[col]
        for row in y..y+wid
          if grid[col][row] == :room
            return true
          end
        end
      end
    end
    return false
  end

  def self.draw(grid)
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

  def self.snake(prng, grid, x, y)
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

  def self.doorify(grid)
    x = -1
    for col in grid
      x += 1
      y = -1
      for cell in col
        y += 1
        if cell == :empty
          neighbors = get_neighbors(grid, x, y)
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

  def self.get_neighbors(grid, x, y)
    output = [nil, nil, nil, nil]
    if x > 0
      output[0] = grid[x-1][y]
    end
    if x < grid.length-1
      output[1] = grid[x+1][y]
    end
    if y > 0
      output[2] = grid[x][y-1]
    end
    if y < grid.length-1
      output[3] = grid[x][y+1]
    end
    return output
  end

  def self.undoorify(prng, grid, room_list)
    for room in room_list
      door_list = get_doors(grid, room).shuffle!(random: prng)
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

  def self.get_doors(grid, room)
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

  def self.start_point(grid, target)
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

  def self.first_dead_end(grid)
    x = 0
    for col in grid
      y = 0
      for row in col
        if dead_end?(grid, x, y)
          return x, y
        end
        y += 1
      end
      x += 1
    end
  return false
  end

  def self.dead_end?(grid, x, y)
    if grid[x]
      if grid[x][y] == :corridor
        neighbor_list = get_neighbors(grid, x, y)
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

  def self.unsnake(grid, coords=nil)
    if coords
      x = coords[0]
      y = coords[1]
      if dead_end?(grid, x, y)
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
      start = first_dead_end(grid)
      if start
        unsnake(grid, start)
      end
    end
    return 0
  end

end


thing = Generator.floor(Random.new(1337), 128, 64, 5, 25, 5, 11) # args need to be odd numbers


puts Generator.draw(thing)
