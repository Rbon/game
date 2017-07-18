class Entity
  attr_reader :room, :name, :volume
  attr_accessor :hp
  def initialize(opts = {})
    @room = opts[:room] || Room.new(look_text: "TestRoom.txt")
    @name = opts[:name] || "[NAME NOT SET]"
    @look_file = opts[:look_file] || "default"
    @room.entity_list.push(self)
    @container = nil
    @hp = 10
    @volume = 1
    @owner = nil
  end

  def attack(*args)
    puts "You cannot attack with the #{@name}."
  end

  def punch(*args)
    puts "You cannot punch with the #{@name}."
  end

  def is_attacked(attacker)
    puts "You attack the #{@name}."
    is_damaged(attacker.attacking_with.attack_damage)
  end

  def is_damaged(amount)
    puts "The #{@name} takes #{amount} damage. [#{@hp} -> #{@hp - amount}]"
    @hp -= amount
  end

  def is_dropped
    @container.entity_list.delete(self)
    @room.entity_list.push(self)
    @container.free_space += @volume
    @container = nil
    puts @room.dropped_item_text(self)
  end

  def is_grabbed(grabber)
    @container = grabber.grabbing_with
    @owner = grabber
    @room.entity_list.delete(self)
    @container.entity_list.push(self)
    @container.free_space -= @volume
    puts "You grab the #{@name} with your #{@owner.grabbing_with.name}."
  end

  def is_looked_at
    puts "You stare longingly at the #{@name}."
  end

  def is_punched(puncher)
    puts "You punch the #{@name} with your #{puncher.attacking_with.name}."
    is_damaged(puncher.attacking_with.attack_damage)
  end
end

class Actor < Entity
  attr_accessor :right_hand, :left_hand, :level, :race, :attacking_with, :grabbing_with

  def initialize(opts = {})
    super(opts)
    @level = 0
    @race = "RACE NOT SET"
    @hp = 10
    @right_hand = RightHand.new(self)
    @left_hand = LeftHand.new(self)
    @attacking_with = nil
    @grabbing_with = nil
  end

  def grab(target, item = nil)
    (item || @right_hand).grab(target)
    @grabbing_with = (item || @right_hand)
  end

  def drop(target)
    target.is_dropped
  end

  def punch(target)
    if @right_hand.entity_list.empty?
      @right_hand.punch(target)
    else
      @right_hand.entity_list[0].punch
    end
  end
end

class Player < Actor
  def initialize(opts)
    super(opts)
    @level = 1
    @race = "human"
    @name = "self"
  end

  def attack(target, item = nil)
    (item || @right_hand).attack(target)
  end

  def look(target)
    target.is_looked_at
  end

  def punch(target)
    if @right_hand.entity_list.empty?
      @right_hand.punch(target)
    else
      @right_hand.entity_list[0].punch(target)
    end
  end

  def is_punched
    puts "You punch yourself."
  end

  def is_damaged(amount)
    puts "You take #{amount} damage. [#{@hp} -> #{@hp - amount}]"
    @hp -= amount
  end

  def is_looked_at
    puts "You are very good looking."
  end
end

class Enemy < Actor
  def attack(target)
    prev_hp = target.hp
    @right_hand.attack(target)
    puts "The enemy attacks you for #{@right_hand.damage}. [#{prev_hp} -> #{target.hp}]"
  end
end

class Weapon < Entity
  def initialize(opts)
    super(opts)
    @damage = 2
  end
  def attack(target)
    target.is_attacked(@owner)
  end
end

class Sword < Weapon
  attr_reader :attack_damage
  def initialize(opts)
    super(opts)
    @name = "sword"
    @damage = 5
  end

  def is_punched(puncher)
    puts "You punch the sword."
    puts "The sword takes no damage."
    puts "You hurt your fist punching a sword."
    puts "You take 1 damage [#{puncher.hp} -> #{puncher.hp - 1}]"
    puncher.hp -= 1
  end
end

class Container < Entity
  attr_accessor :entity_list, :free_space
  def initialize(opts = {})
    @entity_list = []
    @status = opts[:status] || "closed"
    @free_space = 1
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
  attr_reader :owner, :attack_damage
  def initialize(owner)
    super({})
    @name = "right hand"
    @owner = owner
    @attack_damage = 1
  end

  def looked_at
    if @entity_list.empty?
      puts "There is nothing in your right hand."
    else
      puts "In your right hand, you are holding a #{@entity_list[0].name}"
    end
  end

  def attack(target)
    if @entity_list.empty?
      @owner.attacking_with = self
      target.is_punched(@owner)
    else
      @owner.attacking_with = @entity_list[0]
      @entity_list[0].attack(target)
    end
    @owner.attacking_with = nil
  end

  def grab(target)
    if @free_space >= target.volume
      @owner.grabbing_with = self
      target.is_grabbed(@owner)
      @owner.grabbing_with = nil
    end
  end

  def punch(target)
    attack(target)
  end
end

class LeftHand < RightHand
  def initialize(owner)
    super(owner)
    @name = "left hand"
  end
end

class Room
  attr_accessor :entity_list, :name

  def initialize(opts)
    @name = "room"
    @entity_list = []
    @look_file = "look_text/" + opts[:look_file]
  end

  def is_looked_at
    output = File.read(@look_file)
    @entity_list.each do |entity|
      output += "\nThere is a #{entity.name} here."
    end
    puts output
  end
end

class TestRoom < Room
  def dropped_item_text(item)
    "The #{item.name} makes no sound as it falls on the eerie white plane that is the floor here."
  end
end
