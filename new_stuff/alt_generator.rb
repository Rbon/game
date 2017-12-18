## TODO:
## Learn how to make actual circles.


class Grid
  attr_reader(:cell, :set, :range, :len, :wid, :cols, :rows)
  attr_accessor(:sheet)

  def initialize(len, wid)
    @len = len - 1
    @wid = wid - 1
    @cols = 0..@len
    @rows = 0..@wid
    @sheet = Array.new(len) { |col| Array.new(wid) { |row| Tile.new(self) } }
  end

  def cell(x_pos, y_pos)
    if x_pos > @len or x_pos < 0 or y_pos > @wid or y_pos < 0
      return Oob.new(self)
    else
      return @sheet[x_pos][y_pos]
    end
  end

  def range(x_pos, y_pos, len, wid)
    output = Grid.new(len, wid)
    for col in 0..len-1
      for row in 0..wid-1
        output.set(cell(col+x_pos, row+x_pos), col, row)
      end
    end
    return output
  end

  def set(tile, cell_list = [])
    for cell in cell_list
      if cell(cell[0], cell[1]).type != :Oob
        @sheet[cell[0]][cell[1]] = tile
      end
    end
  end

end

class Tile
  attr_reader(:type)

  def initialize(grid)
    @grid = grid
    @type = self.class.to_s.to_sym
    @group = nil
  end

  def coords
    for col in @grid.cols
      if row = @grid.sheet[col].index(self)
        return [col, row]
      end
    end
    return [nil, nil]
  end

  def x_pos
    coords[0]
  end

  def y_pos
    coords[1]
  end

  def adj
    output = []
    output.push(@grid.cell(x_pos+1, y_pos))
    output.push(@grid.cell(x_pos-1, y_pos))
    output.push(@grid.cell(x_pos, y_pos+1))
    output.push(@grid.cell(x_pos, y_pos-1))
    return output
  end

end


class Wall < Tile

  def initialize(grid)
    super(grid)
  end

end


class Oob < Tile

  def initialize(grid)
    super(grid)
  end

end


class Empty < Tile

  def initialize(grid)
    super(grid)
  end

end


class Brush < Tile
  def initialize(grid)
    super(grid)
  end
end


class Clearing
  def initialize(grid, top_left)
    circle = [
                    [2,0], [3,0], [4,0], [5,0], [6,0],
             [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [7,1],
      [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2],
      [0,3], [1,3], [2,3], [3,3], [4,3], [5,3], [6,3], [7,3], [8,3],
      [0,4], [1,4], [2,4], [3,4], [4,4], [5,4], [6,4], [7,4], [8,4],
      [0,5], [1,5], [2,5], [3,5], [4,5], [5,5], [6,5], [7,5], [8,5],
      [0,6], [1,6], [2,6], [3,6], [4,6], [5,6], [6,6], [7,6], [8,6],
             [1,7], [2,7], [3,7], [4,7], [5,7], [6,7], [7,7],
                    [2,8], [3,8], [4,8], [5,8], [6,8]
    ]
    circle.each do |cell|
      cell[0] += top_left[0]
      cell[1] += top_left[1]
    end
    grid.set(Empty.new(grid), circle)
  end
end


class Path
  def initialize(grid, top_left)
    circle = [
                    [2,0], [3,0], [4,0], [5,0], [6,0],
             [1,1],                                    [7,1],
      [0,2],                                                  [8,2],
      [0,3],                                                  [8,3],
      [0,4],                                                  [8,4],
      [0,5],                                                  [8,5],
      [0,6],                                                  [8,6],
             [1,7],                                    [7,7],
                    [2,8], [3,8], [4,8], [5,8], [6,8]
    ]
    circle.each do |cell|
      cell[0] += top_left[0]
      cell[1] += top_left[1]
    end
    grid.set(Empty.new(grid), circle)
  end
end


class Level
  attr_reader(:grid)
  def initialize(prng, grid_w, grid_h)
    @grid = Grid.new(grid_w, grid_h)
    10.times do
      Clearing.new(@grid, [prng.rand(0..grid_w), prng.rand(0..grid_h)])
      Path.new(@grid, [prng.rand(0..grid_w), prng.rand(0..grid_h)])
    end
  end
end


# class Level
  # attr_reader(:grid)

  # def initialize(prng, grid_dimensions, room_lengths, room_widths, max_fails)
    # @len = grid_dimensions[0]
    # @wid = grid_dimensions[1]
    # room_min_len = room_lengths[0] - 1
    # room_max_len = room_lengths[1] - 1
    # room_min_wid = room_widths[0] - 1
    # room_max_wid = room_widths[1] - 1

    # ## make a grid of nothing but wall
    # @grid = Grid.new(@len, @wid)
    # @grid.set(Wall.new(@grid), 0, 0, @len-1, @wid-1)

    # ## add the rooms
    # fails = 0
    # room_id = 0
    # #until fails == max_fails
    # 5.times do
      # x_pos = prng.rand(1 .. @len / 2) * 2 - 1
      # y_pos = prng.rand(1 .. @len / 2) * 2 - 1
      # len = prng.rand(room_min_len / 2 .. room_max_len / 2) * 2
      # wid = prng.rand(room_min_wid / 2 .. room_max_wid / 2) * 2
      # area = @grid.range(x_pos, y_pos, len, wid).sheet.flatten
      # if area.include?()
    # end
  # end
# nd



# g = Level.new(
  # Random.new(1337),     ## a PRNG object
  # [16, 16], ## grid dimensions
  # [5, 10],  ## min and max room length
  # [5, 10],  ## min and max room width
  # 20        ## max fails
# )

# g = Grid.new(5, 5)
# g.set(true, 3, 3)
# r = g.range(1, 1, 3, 3)
# puts g.cell(0, 1).type.inspect
