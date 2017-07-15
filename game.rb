class Entity
  attr_reader :room, :name
  def initialize(opts = {})
    @room = opts[:room] || Room.new(look_text: "TestRoom.txt")
    @name = opts[:name] || "[NAME NOT SET]"
    @look_file = opts[:look_file] || "default"
    @room.entity_list.push(self)
    @container = nil
  end

  def look_text
    File.read("look_text/" + @name)
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
    @right_hand = RightHand.new
  end

  def grab(target)
    target.grabbed(self)
  end

  def drop(target)
    target.dropped
  end

  def look_text
    "You are a level #{@level} #{@race}.\n" + @right_hand.look_text
  end

  def take_damage(amount)
    puts "The #{@name} takes #{amount} damage. [#{@hp} -> #{@hp - amount}]"
    @hp -= amount
  end
end

class Player < Actor
  def initialize(opts)
    super(opts)
    @level = 1
    @race = "human"
    @name = "self"
  end

  def attack(target)
    if @right_hand.entity_list.empty?
      @right_hand.attack(target)
    else
      puts "You attack the #{target.name}."
      @right_hand.entity_list[0].attack(target)
    end
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
    @damage = 5
  end

  def attack(target)
    target.take_damage(@damage)
  end

  def grabbed(grabber)
    @container = grabber.right_hand
    @room.entity_list.delete(self)
    @container.entity_list.push(self)
    puts "You grab the sword."
  end

  def dropped
    @container.entity_list.delete(self)
    @container = nil
    @room.entity_list.push(self)
    puts @room.dropped_item_text(self)
  end

  def punch(target)
    puts "You cannot punch wile you're holding a sword."
  end
end

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
      attack: Attack.new(player: @player),
      drop: Drop.new(player: @player),
      grab: Grab.new(player: @player),
      look: Look.new(player: @player),
      punch: Punch.new(player: @player),
      quit: Halt.new(player: @player)
    }
  end

  def parse
    print " > "
    command_name, target_name = gets.chomp.split(" ", 2)
    command = find_command(command_name.to_sym)
    command.run(target_name)
  end

  def find_command(command_name)
    @commands[command_name] || BadCommand.new(command_name)
  end

  def attack(target)
    entity = search(@player.targets, target)
    entity ? @player.attack(entity) : bad_target(target)
  end
end

class Command
  def initialize(opts)
    @player = opts[:player]
  end

  def find_target(target_name)
    range.each do |entity|
      return entity if entity.name == target_name
    end
    false
  end

  def bad_target(target_name)
    puts "Unknown #{self.class} target: #{target_name}"
  end
end

class BadCommand
  def initialize(command_name)
    @command_name = command_name
  end

  def run(junk)
    puts "Unknown command: #{@command_name}"
  end
end

class Look < Command
  def range
    [
      @player,
      @player.right_hand,
      *@player.right_hand.entity_list,
      *@player.room.entity_list
    ]
  end

  def run(target_name)
    if target_name
      target = find_target(target_name)
    else
      target = @player.room
    end
    if target
      puts target.look_text
    else
      bad_target(target_name)
    end
  end
end

class Halt < Command
  def run(junk)
    exit
  end
end

class Grab < Command
  def range
    @player.room.entity_list
  end

  def run(target_name)
    if target_name
      target = find_target(target_name)
    end
    if target
      @player.grab(target)
    else
      bad_target(target_name)
    end
  end
end

class Drop < Command
  def range
    @player.right_hand.entity_list
  end

  def run(target_name)
    if target_name
      target = find_target(target_name)
    end
    if target
      @player.drop(target)
    else
      bad_target(target_name)
    end
  end
end

class Attack < Command
  def range
    @player.room.entity_list
  end

  def run(target_name)
    if target_name
      target = find_target(target_name)
    end
    if target
      @player.attack(target)
    else
      bad_target(target_name)
    end
  end
end

class Punch < Attack
  def run(target_name)
    if target_name
      target = find_target(target_name)
    end
    if target
      if @player.right_hand.entity_list.empty?
        @player.right_hand.attack(target)
      else
        @player.right_hand.entity_list[0].punch(target)
      end
    end
  end
end

class Container
  attr_reader :name
  attr_accessor :entity_list
  def initialize(opts = {})
    @name = opts[:name]
    @entity_list = []
    @status = opts[:status] || "closed"
  end

  def look_text
    send(@status + "_text")
  end

  def open_text
    return "There is nothing in #{@name}." if @entity_list.empty?
    output = "In the #{@name} there is:"
    @entity_list.each do |entity|
      output += "\na #{entity.name}"
    end
    output
  end

  def closed_text
    "The #{@name} is closed, and you cannot see what is inside of it."
  end
end

class RightHand < Container
  def initialize
    super(name: "right hand")
  end

  def look_text
    return "There is nothing in your right hand." if @entity_list.empty?
    "In your right hand, you are holding a #{@entity_list[0].name}"
  end

  def attack(target)
    puts "You punch the #{target.name}."
    target.take_damage(1)
  end
end

class Room
  attr_accessor :entity_list

  def initialize(opts)
    @entity_list = []
    @look_file = "look_text/" + opts[:look_file]
  end

  def look_text
    output = File.read(@look_file)
    @entity_list.each do |entity|
      output += "\nThere is a #{entity.name} here."
    end
    output
  end
end

class TestRoom < Room
  def dropped_item_text(item)
    "The #{item.name} makes no sound as it falls on the eerie white plane that is the floor here."
  end
end

Main.new.run
