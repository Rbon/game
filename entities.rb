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

  def looked_at
    puts "You stare longingly at the #{@name}."
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


  def punch(target)
    if @right_hand.entity_list.empty?
      @right_hand.punch(target)
    else
      @right_hand.entity_list[0].punch
    end
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
      @right_hand.entity_list[0].attack(target)
    end
  end

  def look(target)
    target.looked_at
  end

  def punch(target)
    if @right_hand.entity_list.empty?
      @right_hand.punch(target)
    else
      @right_hand.entity_list[0].punch(target)
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
    puts "You cannot punch while you're holding a sword."
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

  def punch(target)
    attack(target)
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
