class Actor
  attr_reader :name
  attr_accessor :hp

  def initialize(opts = {})
    @name = opts[:name] || "[NAME NOT SET]"
    @room = opts[:room]
    @room.push(self)
    @hp = 10
    @right_hand = Sword.new
  end

  def targets
    output = Array[*@room]
    output.delete(self)
    output
  end
end

class Player < Actor
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
    @room = []
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "enemy crab")
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
    @commands = {
      attack: :attack,
      quit: :halt
    }
  end

  def parse
    print " > "
    command, target = gets.chomp.split(" ", 2)
    run_command(command.to_sym, target)
  end

  def run_command(command, target)
    if @commands[command]
      send(@commands[command], target)
    else
      bad_command(command)
    end
  end

  def bad_command(command)
    puts "Unknown command: #{command}"
    parse
  end

  def search(list, target)
    output = false
    list.each do |entity|
      if entity.name == target
        output = entity
        break
      end
    end
    output
  end

  def attack(target)
    entity = search(@player.targets, target)
    entity ? @player.attack(entity) : bad_target(target)
  end

  def bad_target(target)
    puts "Unknown target: #{target}"
    parse
  end

  def halt(target)
    exit
  end
end



Main.new.run
