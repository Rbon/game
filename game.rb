require "./entities.rb"

class Main
  def initialize
    @room = TestRoom.new(look_file: "TestRoom.txt")
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "crab")
    @sword = Sword.new(room: @room)
    @grammar = Grammar.new
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
end

    # @range_list = {
      # room: @player.room.entity_list,
      # hands: [
        # @player.right_hand,
        # @player.right_hand.entity_list,
        # @player.left_hand,
        # @player.left_hand.entity_list
      # ],
      # everything: [
          # @player.room.entity_list,
          # @player.right_hand,
          # @player.right_hand.entity_list,
          # @player.room
      # ],
      # held: [
        # @player.right_hand.entity_list,
        # @player.left_hand.entity_list
      # ],
      # backpack: [
        # @player.backpack.entity_list
      # ]
    # }

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

Main.new.run
