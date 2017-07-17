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
      @user.parse
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
    command = @commands[command_name.to_sym].new || BadCommand.new(command_name)
    target_list = @range_list[command.range]
    command.run(
      actor: @player,
      target_list: target_list,
      target_name: target_name
    )
  end
end

Main.new.run
