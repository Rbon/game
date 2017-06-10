class Actor
  attr_reader :name
  attr_accessor :hp

  def initialize(opts = {})
    @name = opts[:name] || "[NAME NOT SET]"
    @attack_verb = opts[:attack_verb] || "attacks"
    @hp = 10
    @right_hand = Sword.new
  end

  def attack(target)
    prev_hp = target.hp
    @right_hand.attack(target)
    puts "#{@name.capitalize} #{@attack_verb} #{target.name} for #{@right_hand.damage} damage. [#{prev_hp} -> #{target.hp}]"
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
    @player = Actor.new(name: "you", attack_verb: "attack")
    @enemy = Actor.new(name: "the enemy")
    @user = User.new(player: @player, system: System.new)
  end

  def run
    @user.run_command(:attack, @enemy)
    @enemy.attack(@player)
  end
end

class User
  def initialize(opts)
    @player = opts[:player]
    @system = opts[:system]
    @commands = {
      attack: [@player, :attack],
      quit: [@system, :quit]
    }
  end

  def run_command(command, target = nil)
    command = @commands[command]
    command[0].send(command[1], target)
  end
end

class System
  def halt
    exit
  end
end

Main.new.run
