module Target
  class Target
    def initialize(opts)
      @actor = opts[:actor]
    end
  end

  class Everything < Target
    def list
      [
        @actor.room,
        @actor.room.entity_list,
        @actor.right_hand.entity_list,
        @actor.left_hand.entity_list
      ]
    end
  end

  class Tool < Target
    def list
      [
        @actor.right_hand,
        @actor.right_hand.entity_list,
        @actor.left_hand,
        @actor.left_hand.entity_list
      ]
    end
  end

  class Room < Target
    def list
      [
        @actor.room.entity_list
      ]
    end
  end
end

class Action
  def initialize(opts)
    @actor = opts[:actor]
    @action = opts[:action]
    @target = opts[:target]
    @prep = opts[:prep]
    @tool = opts[:tool]
    @damage = opts[:damage]
    @target_list = Target::Room
    @tool_list = Target::Tool
  end

  def search_entities(args)
    args[:range].flatten.each { |item| return item if item.name == args[:name]}
    NullEntity.new(name: args[:name])
  end

  def resolve_sentence(args)
    if @target
      @target = search_entities(
        range: @target_list.new(actor: @actor).list,
        name: @target
      )
    else
      @target = NoTargetEntity.new
    end
    if @prep
      if @tool
        @tool = search_entities(
          range: @tool_list.new(actor: @actor).list,
          name: @tool
        )
      else
        @tool = NoPrepEntity.new
      end
    end
    args
  end

  def state
    {
      actor: @actor,
      action: @action,
      target: @target,
      prep: @prep,
      tool: @tool,
      damage: @damage
    }
  end
end

class BadAction < Action
  def act
    puts "Unknown action: #{@action}"
  end
end

class PassToTarget < Action
  def act
    @target.react(state)
  end
end

class PassToBackpack < Action
  def act
    @tool = @actor.backpack
    @tool.act(state)
  end
end

class FistAttack < Action
  def act
    if @tool.entity_list.empty?
      @action = :punch
    else
      @tool = @tool.entity_list[0]
    end
    @target.react(state)
  end
end

class Attack < Action
  def initialize(opts)
    super
    @target_list = Target::Room
    @tool_list = Target::Tool
  end

  def act
    puts "You attack the #{@target.name} with your #{@tool.name}."
    @action = :damage
    @damage = @tool.damage
    @target.react(state)
  end
end

class PassAttackToHand < Attack
  def act
    @tool ||= @actor.right_hand
    @tool.act(state)
  end
end

class AttackFail < Action
  def act
    puts "You cannot attack with #{@entity.name}."
  end
end

class Damage < Action
  def act
    puts(
      "The #{@target.name} takes #{@damage} damage. " +
      "[#{@target.hp} -> #{@target.hp - @damage}]"
    )
    @target.hp -= @damage
  end
end

class DamagePlayer < Action
  def act
    puts "You take #{@damage} damage. [#{@actor.hp} -> #{@actor.hp - @damage}]"
    @actor.hp -= @damage
  end
end

class Drop < Action
  def act
    @target.container = @target.room
    puts "You drop the #{@target.name} on the floor."
  end
end

class Grab < Action
  def act
    @target.container = @tool
    puts "You grab the #{@target.name} with your #{@tool.name}."
  end
end

class GrabSelf < Action
  def act
    puts "You take firm hold of yourself."
  end
end

class PlayerLook < Action
  def initialize(opts)
    super
    @target_list = Target::Everything
  end

  def act
    if @target.class == NoTargetEntity
      @target = @actor.room
    end
    @target.react(state)
  end
end

class LookFist < Action
  def act
    if @target.entity_list.empty?
      puts "There is nothing in your #{@target.name}."
    else
      puts "In your right hand, you are holding a #{@target.entity_list[0].name}."
    end
  end
end

class Look < Action
  def act
    puts "It's a #{@target.name}"
  end
end

class LookSelf < Action
  def act
    [
      @actor.left_hand,
      @actor.right_hand,
      @actor.backpack
    ].each do |target|
      @target = target
      target.react(state)
    end
  end
end

class LookRoom < Action
  def act
    puts "This is a room."
    @target.entity_list.each do |entity|
      puts "  There is a #{entity.name} here."
    end
  end
end

class Punch < Action
  def act
    puts "You punch the #{@target.name} with your #{@tool.name}."
    @action = :damage
    @damage = @tool.damage
    @target.react(state)
  end
end

class PunchSelf < Action
  def act
    puts "You punch yourself."
    @action = :damage
    @damage = 1
    @actor.react(state)
  end
end

class PunchSword < Action
  def act
    puts "You punch the sword."
    puts "The sword takes no damage."
    puts "You hurt your fist punching a sword."
    @action = :damage
    @damage = 1
    @actor.react(state)
  end
end

class Stash < Action
  def act
    puts "You stash your #{@target.name} in your #{@tool.name}."
    @target.container = @tool
  end
end

class Unstash < Action
  def act
    puts "You grab your #{@target.name} from your backpack."
    @target.container = @actor.right_hand
  end
end

## BAD REACTIONS
class BadTargetAction < Action
  def act
    puts "There is no \"%s\" to %s here." % [@target.name, @action]
  end
end

class DontSeeTarget < Action
  def act
    puts "You don't see any \"#{@target.name}\" here."
  end
end

class NotInBackpack < Action
  def act
    puts "There is no \"#{@target.name}\" in your backpack."
  end
end

class NotHolding < Action
  def act
    puts "You're not holding any \"#{@tool.name}\"."
  end
end

class NoPrepAction < Action
  def act
    puts "#{@action} #{@target} #{@prep} what?".capitalize
  end
end

class NoTargetAction < Action
  def act
    puts "#{@action} what?".capitalize
  end
end

## SPECIAL ACTIONS
class Halt < Action
  def act
    exit
  end
end

