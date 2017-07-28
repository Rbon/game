require "./actions.rb"

class Entity
  attr_reader :room, :name, :volume
  attr_accessor :hp, :owner
  def initialize(opts = {})
    @room = opts[:room]
    @container = opts[:container] || @room
    @container.entity_list.push(self)
    @name = opts[:name] || "[NAME NOT SET]"
    @look_file = opts[:look_file] || "default"
    @hp = 10
    @volume = 1
    @owner = nil
    @action_list = {
      attack: AttackFail,
      punch: AttackFail,
    }
    @reaction_list = {
      attack: Attack,
      damage: Damage,
      drop: Drop,
      grab: Grab,
      look: Look,
      punch: Punch,
      stash: Stash,
      unstash: Unstash
    }
  end

  def act(args)
    list = args[:list] || @action_list
    args[:entity] = self
    (list[args[:action]] || BadAction).new.act(args)
  end

  def react(args)
    args[:list] = @reaction_list
    act(args)
  end

  def container=(container)
    @container.entity_list.delete(self)
    @container = container
    @container.entity_list.push(self)
  end
end

class NullEntity < Entity
  def initialize(opts)
    @name = opts[:name]
    @action_list = {
      attack: NotHolding,
      punch: NotHolding
    }
    @reaction_list = {
      attack: NullAttack,
      drop: NullDrop,
      grab: NullGrab,
      look: NullLook,
      punch: NullPunch,
      stash: NullStash,
      unstash: NullUnstash
    }
  end
end

class NoPrepEntity < Entity
  def initialize
    @action_list = {
      attack: NoPrepAction
    }
  end
end

class Actor < Entity
  attr_accessor :right_hand, :left_hand, :level, :race
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
    @action_list.update(
      look: PassToTarget,
      grab: PassAttackToHand,
      attack: PassAttackToHand,
      drop: PassAttackToHand,
      punch: PassAttackToHand,
      stash: PassToBackpack,
      unstash: PassToBackpack
    )
  end
end

class Player < Actor
  attr_accessor :backpack
  def initialize(opts)
    super(opts)
    @level = 1
    @race = "human"
    @name = "self"
    @backpack = Backpack.new(owner: self, room: @room)
    @action_list.update(
      quit: Halt,
    )
    @reaction_list.update(
      punch: PunchSelf,
      damage: DamagePlayer,
      grab: GrabSelf,
      look: LookSelf
    )
  end

  def act(args)
    list = args[:list] || @action_list
    action = (list[args[:action]] || BadAction).new(actor: self)
    action.resolve_sentence(args)
    action.act(args)
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

class Sword < Entity
  attr_reader :damage
  def initialize(opts)
    super
    @name = "sword"
    @damage = 5
    @action_list[:attack] = PassToTarget
    @reaction_list.update(
      punch: PunchSword
    )
  end
end

class Backpack <  Entity
  attr_accessor :entity_list
  def initialize(opts)
    super
    @name = "backpack"
    @owner = opts[:owner]
    @entity_list = []
    @action_list.update(
      stash: Stash,
      unstash: Unstash
    )
  end
end

class RightHand < Entity
  attr_reader :owner, :damage, :entity_list
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
      drop: PassToTarget,
      grab: PassToTarget
    )
    @reaction_list[:look] = LookFist
    @damage = 1
  end
end

class LeftHand < RightHand
  def initialize(opts)
    super
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
