require "./alt_generator.rb"


def draw(grid)
  output = ""
  for row in grid.rows
    for col in grid.cols
      case grid.cell(col, row).type
      when :Tile
        output << " "
      when :Empty
        output << "."
      end
    end
    output  << "\n"
  end
  return  output
end

def draw2
  output = ""
  for row in @grid.rows
    for col in @grid.cols
      case @grid.cell(col, row).group
      when nil
        output << "  "
      else
        output << @grid.cell(col, row).group.to_s.rjust(2, '0')
      end
    end
    output << "\n"
  end
  return output
end



prng = Random.new(1337)
l = Level.new(prng, 64, 32)
puts draw(l.grid)

