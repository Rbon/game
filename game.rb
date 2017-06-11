class Actor
  attr_reader :name
  attr_accessor :hp

  def initialize(opts = {})
    @name = opts[:name] || "[NAME NOT SET]"
    @room = opts[:room]
    @room[@name] = self
    @hp = 10
    @right_hand = Sword.new
  end
end

class Player < Actor
  attr_reader :room

  def attack(target)
    prev_hp = target.hp
    @right_hand.attack(target)
    puts "You attack the enemy for #{@right_hand.damage}. [#{prev_hp} -> #{target.hp}]"
  end
end

class Enemy < Actor
  def attack(target)
    prev_hp = target.hp
    @right_hand.attack(target)
    puts "The enemy attacks you for #{@right_hand.damage}. [#{prev_hp} -> #{target.hp}]"
  end
end

class Sword
  attr_reader :damage

  def initialize
    @damage = 1
  end
  def attack(target)
    target.hp -= @damage
  end
end

class Main
  def initialize
    @room = {}
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "enemy")
    @user = User.new(player: @player)
  end

  def run
    loop do
      @user.parse
      @enemy.attack(@player)
    end
  end
end

class User
  def initialize(opts)
    @player = opts[:player]
    @system = opts[:system]
    @commands = {
      attack: :attack,
      quit: :halt
    }
  end

  def parse
    print " > "
    command, target = gets.chomp.split
    run_command(command.to_sym, target)
  end

  def run_command(command, target)
    self.send((@commands[command] || :bad_command), target)
  end

  def bad_command(target)
    puts "Unknown command."
    parse
  end

  def attack(target)
    if @player.room[target] == nil
      puts "Unknown target: #{target}"
      parse
    else
      @player.attack(@player.room[target])
    end
  end

  def halt(target)
    exit
  end
end



Main.new.run
