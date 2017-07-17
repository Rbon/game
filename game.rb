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
      held: @player.right_hand.entity_list,
      everything: [
          @player.room.entity_list,
          @player.right_hand,
          @player.right_hand.entity_list,
          @player.room
      ]
    }
    @commands = {
      attack: Attack,
      drop: Drop,
      grab: Grab,
      look: Look,
      punch: Punch,
      quit: Halt
    }
  end

  def parse
    print " > "
    command_name, target_name = gets.strip.chomp.split(" ", 2)
    command = find_command(command_name)
    target_list = @range_list[command.range]
    command.run(
      actor: @player,
      target_list: target_list,
      target_name: target_name
    )
  end

  def parse
    print " > "
    line = gets.strip.chomp.split(" ", 2)
    line[1] = line[1].split("with", 2) if line[1]
    line.flatten.map { |section| section.strip }
  end

  def run_command(line)
    proper_line = {player: @player}
    verb = verbify(line[0])
    proper_line[:subject] = subjectify(line[1], @range_list[verb.range])
    proper_line[:object] = objectify(line[4], @range_list[:held])
    verb.run(proper_line)
  end

  def verbify(line)
    lookup = @commands[line.to_sym]
    lookup ? lookup.new : BadCommand.new(command_name)
  end

  def subjectify(subject, range)
    if subject
      range.flatten.each { |entity| return entity if entity.name == subject }
      BadTarget.new(subject)
    else
      false
    end
  end

  def objectify(object, range)
    if object
      range.flatten.each { |entity| return entity if entity.name == object }
      BadItem.new(object)
    else
      false
    end
  end
end

Main.new.run
