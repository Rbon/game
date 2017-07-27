require "./actions.rb"

class Entity
  attr_reader :room, :name, :volume
  attr_accessor :hp, :container, :owner
  def initialize(opts = {})
    @room = opts[:room]
    @room.entity_list.push(self) if @room
    @name = opts[:name] || "[NAME NOT SET]"
    @look_file = opts[:look_file] || "default"
    @hp = 10
    @volume = 1
    @container = nil
    @owner = nil
    @action_list = {
      attack: ItemCannotAttack,
      drop: DropReaction,
      grab: GrabReaction,
      punch: ItemCannotAttack,
      error: BadAction
    }
    @reaction_list = {
      attack: AttackReaction,
      drop: DropReaction,
      grab: GrabReaction,
      look: LookReaction,
      punch: PunchReaction
    }
  end

  def act(args)
    @action_list[args[:action]].new(
      entity: self,
      subject: args[:subject],
      object: args[:object]
    ).act
  end

  def react(args)
    @reaction_list[args[:action]].new(
      entity: self,
      actor: args[:actor]
    ).act
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
    puts "You drop the #{@name} on the floor."
  end

  def is_grabbed(grabber)
    @container = grabber.grabbing_with
    @owner = grabber
    @room.entity_list.delete(self)
    @container.entity_list.push(self)
    @container.free_space -= @volume
    puts "You grab the #{@name} with your #{@owner.grabbing_with.name}."
  end

  def is_stashed(actor)
    actor.right_hand.entity_list.delete(self)
    actor.backpack.entity_list.push(self)
    puts "You stash the #{@name} in your backpack."
  end

  def is_unstashed(actor)
    actor.backpack.entity_list.delete(self)
    actor.right_hand.entity_list.push(self)
    puts "You grab the #{@name} from your backpack."
  end
end

class BadEntity < Entity
  def volume
    0
  end

  def attack(*args)
    puts "You don't have any \"#{@name}\" at the ready"
  end

  def complain(*args)
    puts "You don't see any \"#{@name}\" here."
  end

  def is_dropped(*args)
    puts "You're not holding any \"#{@name}\"."
  end

  def is_unstashed(*args)
    puts "There is no \"#{@name}\" in your backpack."
  end

  alias :punch :attack
  alias :is_attacked :complain
  alias :is_punched :complain
  alias :is_looked_at :complain
  alias :is_grabbed :complain
  alias :is_stashed :attack
end

class Actor < Entity
  attr_accessor :right_hand, :left_hand, :level, :race, :attacking_with, :grabbing_with

  def initialize(opts = {})
    super(opts)
    @level = 0
    @race = "RACE NOT SET"
    @hp = 10
    @right_hand = RightHand.new(owner: self, room: @room)
    @left_hand = LeftHand.new(owner: self, room: @room)
    @attacking_with = nil
    @grabbing_with = nil
    @volume = 10
    @action_list = {
      look: ActorLook,
      grab: ActorGrab,
      attack: ActorAttack,
      drop: ActorDrop,
      punch: ActorPunch
    }
  end
end

class Player < Actor
  attr_accessor :backpack
  def initialize(opts)
    super(opts)
    @level = 1
    @race = "human"
    @name = "self"
    @backpack = Backpack.new(self)
    @action_list[:quit] = Halt
    @reaction_list.update(
      punch: PunchSelf,
      look: PlayerLookReaction
    )
  end

  def is_damaged(amount)
    puts "You take #{amount} damage. [#{@hp} -> #{@hp - amount}]"
    @hp -= amount
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
    super
    @damage = 2
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

  def is_looked_at
    send(@status + "_text")
  end

  def open_text
    if @entity_list.empty?
      puts "There is nothing in the #{@name}."
      return
    else
      output = "In the #{@name} there is:"
      @entity_list.each do |entity|
        output += "\n  a #{entity.name}"
      end
      puts output
    end
  end

  def closed_text
    puts "The #{@name} is closed, and you cannot see what is inside of it."
  end

  def stash(item)
    if @free_space >= item.volume
      item.is_stashed(@owner)
    else
      puts "The #{item.name} is too big to fit in the #{@name}."
    end
  end

  def unstash(item)
    item.is_unstashed(@owner)
  end
end

class Backpack <  Container
  def initialize(owner)
    super({})
    @name = "backpack"
    @owner = owner
  end
  def is_looked_at
    open_text
  end
end

class RightHand < Entity
  attr_reader :owner, :attack_damage, :entity_list
  attr_accessor :free_space
  def initialize(opts)
    super
    @name = "right hand"
    @owner = opts[:owner]
    @attack_damage = 1
    @entity_list = []
    @free_space = 1
    @action_list.update(
      attack: FistAttack,
      punch: FistAttack,
      drop: FistDrop,
      grab: FistGrab
    )
  end

  def is_looked_at
    if @entity_list.empty?
      puts "There is nothing in your #{@name}."
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
    else
      puts "The #{target.name} is too big to hold."
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

class Bag < Container
  def name
    "bag"
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
      next if entity.class == Player
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
