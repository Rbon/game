class Entity
  attr_reader :name, :room
  def initialize(opts)
    @room = opts[:room] || TestRoom.new
    @name = opts[:name] || "[NAME NOT SET]"
    @room.entity_list.push(self)
  end

  def grabbed(junk)
    puts "You cannot grab the #{@name}."
  end
end

class Actor < Entity
  attr_accessor :hp, :right_hand, :level, :race

  def initialize(opts = {})
    super(opts)
    @level = 0
    @race = "RACE NOT SET"
    @hp = 10
    @right_hand = nil
  end

  def targets
    output = Array[*@room]
    output.delete(self)
    output
  end

  def grab(target)
    target.grabbed(self)
  end

  def look_text
    "You are a level #{@level} #{@race}.
    test."
  end
end

class Player < Actor
  def initialize(opts)
    super(opts)
    @level = 1
    @race = "human"
  end

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

class Sword < Entity
  def initialize(opts)
    super(opts)
    @name = "sword"
    @damage = 1
  end

  def attack(target)
    target.hp -= @damage
  end

  def grabbed(grabber)
    grabber.right_hand = self
    puts "You grab the sword."
  end
end

class Main
  def initialize
    @room = TestRoom.new
    @player = Player.new(room: @room)
    @enemy = Enemy.new(room: @room, name: "enemy crab")
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
      attack: :attack,
      grab: :grab,
      look: :look,
      quit: :halt
    }
  end

  def parse
    print " > "
    command_name, target_name = gets.chomp.split(" ", 2)
    command = find_command(command_name.to_sym)
    if target_name != nil
      target = find_target(target_name)
    else
      target = nil
    end
    if command == :bad_command
      bad_command(command_name)
    elsif target == :bad_target
      bad_target(target_name)
    else
      send(command, target)
    end
  end

  def find_command(command_name)
    @commands[command_name] || :bad_command
  end

  def find_target(target_name)
    @player.room.entity_list.each do |entity|
      if entity.name == target_name
        return entity
      end
    end
    :bad_target
  end

  def bad_command(command)
    puts "Unknown command: #{command}"
    parse
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

  def look(target)
    target ||= @player.room
    puts target.look_text
  end

  def grab(entity_name)
    @player.grab(entity_name)
  end
end

class TestRoom
  attr_reader :look_text
  attr_accessor :entity_list
  def initialize
    @look_text = File.read("TestRoom.txt")
    @entity_list = []
  end
end

Main.new.run
