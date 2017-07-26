require "./commands.rb"
require "./entities.rb"

class Main
  def initialize
    @room = TestRoom.new(look_file: "TestRoom.txt")
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "crab")
    @user = User.new(player: @player)
    @sword = Sword.new(room: @room)
  end

  def run
    loop do
      puts
      command = @user.parse
      @user.run_command(command)
      # @enemy.attack(@player)
    end
  end
end

class User
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
    @commands = {
      attack: Attack,
      drop: Drop,
      grab: Grab,
      look: Look,
      punch: Punch,
      quit: Halt,
      stash: Stash,
      unstash: Unstash
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
    verb = verbify(line[0])
    targets[:subject] = subjectify(line[1], @range_list[verb.range])
    targets[:object] = objectify(line[2], @range_list[:hands])
    @player.act(action: verb.action, targets: targets)
  end

  def verbify(line)
    lookup = @commands[line.to_sym]
    lookup ? lookup.new : BadCommand.new(line)
  end

  def subjectify(subject, range)
    if subject and range
      range.flatten.each { |entity| return entity if entity.name == subject }
      BadEntity.new(name: subject)
    else
      false
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
