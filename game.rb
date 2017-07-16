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
    @commands = {
      attack: PlayerAction.new(
        action: :attack,
        range: @player.room.entity_list
      ),
      drop: PlayerAction.new(
        range: @player.right_hand.entity_list,
        action: :drop
      ),
      grab: PlayerAction.new(
        range: @player.room.entity_list,
        action: :grab
      ),
      look: Look.new(
        range: [
          @player.room.entity_list,
          @player.right_hand,
          @player.right_hand.entity_list
        ]
      ),
      punch: PlayerAction.new(
        action: :punch,
        range: @player.room.entity_list
      ),
      quit: Halt.new,
      test: Test.new(@player.room.entity_list)
    }
  end

  def parse
    print " > "
    command_name, target_name = gets.chomp.split(" ", 2)
    command = @commands[command_name.to_sym] || BadCommand.new(command_name)
    command.run(@player, target_name)
  end
end

Main.new.run
