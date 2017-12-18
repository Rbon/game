class Input
  def initialize
    @input_map = {
      "l" => :move_right,
      "h" => :move_left,
      "k" => :move_up,
      "j" -> :move_down
    }
  end

  def parse(args)
    @input_map[args[:input]]
  end
end
