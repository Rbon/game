require "./entities.rb"

class Main
  def initialize
    @room = TestRoom.new(look_file: "TestRoom.txt")
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "crab")
    @commands = Commands.new(player: @player)
    @sword = Sword.new(room: @room)
  end

  def run
    loop do
      puts
      command = @commands.parse
      @commands.run_command(command)
      # @enemy.attack(@player)
    end
  end
end

class Commands
  def initialize(opts)
    @player = opts[:player]
    @range_list = {
      room: @player.room.entity_list,
      hands: [
        @player.right_hand,
        @player.right_hand.entity_list,
        @player.left_hand,
        @player.left_hand.entity_list
      ],
      everything: [
          @player.room.entity_list,
          @player.right_hand,
          @player.right_hand.entity_list,
          @player.room
      ],
      held: [
        @player.right_hand.entity_list,
        @player.left_hand.entity_list
      ],
      backpack: [
        @player.backpack.entity_list
      ]
    }
    @command_ranges = {
      attack: :room,
      drop: :hands,
      grab: :room,
      look: :everything,
      punch: :room,
      quit: :none,
      stash: :held,
      unstash: :backpack
    }
  end

  def parse
    print " > "
    line = gets.strip.chomp.split(" ", 2)
    line[1] = line[1].split("with", 2) if line[1]
    line.flatten.map { |section| section.strip }
  end

  def run_command(line)
    targets = {}
    verb = line[0].to_sym
    range = @command_ranges[verb] || :error
    subject =  subjectify(line[1], @range_list[range])
    object = objectify(line[2], @range_list[:hands])
    @player.act(action: verb, target: subject, tool: object, actor: @player)
  end

  def subjectify(subject, range)
    if subject and range
      range.flatten.each { |entity| return entity if entity.name == subject }
      BadEntity.new(name: subject)
    else
      BadEntity.new(name: subject)
    end
  end

  def objectify(object, range)
    if object
      range.flatten.each { |entity| return entity if entity.name == object }
      BadEntity.new(name: object)
    else
      false
    end
  end
end

Main.new.run
