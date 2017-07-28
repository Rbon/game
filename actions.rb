module Target
  class Target
    def initialize(opts)
      @actor = opts[:actor]
    end
  end

  class Everything < Target
    def list
      [
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
end

class Action
  def initialize(opts)
    @target_list = opts[:target_list].new(actor: opts[:actor]).list
    @tool_list = opts[:tool_list].new(actor: opts[:actor]).list
  end

  def search_entities(args)
    args[:range].flatten.each { |item| return item if item.name == args[:name]}
    NullEntity.new(name: args[:name])
  end

  def resolve_sentence(args)
    args[:target] = search_entities(range: @target_list, name: args[:target])
    if args[:prep]
      if args[:tool]
        args[:tool] = search_entities(range: @tool_list, name: args[:tool])
      else
        args[:tool] = NoPrepEntity.new
      end
    end
    args
  end
end

class BadAction < Action
  def initialize(opts)
  end

  def resolve_sentence(args)
  end

  def act(args)
    puts "Unknown action: #{args[:action]}"
  end
end

class PassToTarget
  def act(args)
    args[:target].react(args)
  end
end

class PassToBackpack
  def act(args)
    args[:tool] = args[:actor].backpack
    args[:tool].act(args)
  end
end

class FistAttack
  def act(args)
    if args[:tool].entity_list.empty?
      args[:action] = :punch
    else
      args[:tool] = args[:tool].entity_list[0]
    end
    args[:target].react(args)
  end
end

class Attack < Action
  def initialize(opts)
    super(
      actor: opts[:actor],
      target_list: Target::Everything,
      tool_list: Target::Tool
    )
  end

  def act(args)
    puts "You attack the #{args[:target].name} with your #{args[:tool].name}."
    args.update(
      action: :damage,
      amount: args[:tool].damage
    )
    args[:target].react(args)
  end
end

class PassAttackToHand < Attack
  def act(args)
    args[:tool] ||= args[:actor].right_hand
    args[:tool].act(args)
  end
end

class AttackFail
  def act
    puts "You cannot attack with #{@entity.name}."
  end
end

class Damage
  def act(args)
    puts(
      "The #{args[:target].name} takes #{args[:amount]} damage. " +
      "[#{args[:target].hp} -> #{args[:target].hp - args[:amount]}]"
    )
    args[:target].hp -= args[:amount]
  end
end

class DamagePlayer
  def act
    puts "You take #{@amount} damage. [#{@entity.hp} -> #{@entity.hp - @amount}]"
    @entity.hp -= @amount
  end
end

class Drop
  def act(args)
    args[:tool].entity_list.delete(args[:target])
    args[:actor].room.entity_list.push(args[:target])
    puts "You drop the #{args[:target].name} on the floor."
  end
end

class Grab
  def act(args)
    args[:target].container = args[:tool]
    puts "You grab the #{args[:target].name} with your #{args[:tool].name}."
  end
end

class GrabSelf
  def act
    puts "You take firm hold of yourself."
  end
end

class Look
  def initialize(opts)
    @target_range = Range.new(opts).range
  end

  def act(args)
    puts "It's a #{args[:target].name}."
  end
end

class LookFist
  def act(args)
    if args[:target].entity_list.empty?
      puts "There is nothing in your #{args[:target].name}."
    else
      puts "In your right hand, you are holding a #{args[:target].entity_list[0].name}."
    end
  end
end

class LookSelf
  def act(args)
    [
      args[:actor].left_hand,
      args[:actor].right_hand,
      args[:actor].backpack
    ].each do |target|
      args[:target] = target
      target.react(args)
    end
  end
end

class Punch
  def act(args)
    puts "You punch the #{args[:target].name} with your #{args[:tool].name}."
    args.update(
      action: :damage,
      amount: args[:tool].damage
    )
    args[:target].react(args)
  end
end

class PunchSelf
  def act(args)
    puts "You punch yourself."
    args[:action] = :damage
    args[:actor].react(args)
  end
end

class PunchSword
  def act
    puts "You punch the sword."
    puts "The sword takes no damage."
    puts "You hurt your fist punching a sword."
    @actor.react(
      action: :damage,
      amount: 1
    )
  end
end

class Stash
  def act(args)
    puts "You stash your #{args[:target]} in your #{args[:tool]}."
    args[:target].container = args[:tool]
  end
end

class Unstash
  def act(args)
    puts "You grab your #{args[:target].name} from your backpack."
    args[:target].container = args[:actor].right_hand
  end
end

## BAD REACTIONS
class NullAction
  def resolve_sentence
  end
end

class NullAttack < NullAction
  def act(args)
    puts "There is no \"#{args[:target].name}\" to attack here."
  end
end

class NullDrop < NullAction
  def act(args)
    puts "You aren't holding any \"#{args[:target].name}\"."
  end
end

class NullGrab < NullAction
  def act(args)
    puts "There is no \"#{args[:target].name}\" to grab here."
  end
end

class NullLook < NullAction
  def act(args)
    puts "You don't see any \"#{args[:target].name}\" here."
  end
end

class NullPunch < NullAction
  def act(args)
    puts "There is no \"#{args[:target].name}\" to punch here."
  end
end

class NullStash < NullAction
  def act(args)
    puts "You aren't holding any \"#{args[:target].name}\"."
  end
end

class NullUnstash < NullAction
  def act(args)
    puts "There is no \"#{args[:target].name}\" in your backpack."
  end
end

class NotHolding < NullAction
  def act(args)
    puts "You're not holding any \"#{args[:tool].name}\"."
  end
end

class NoPrepAction < NullAction
  def act(args)
    puts "#{args[:action]} #{args[:target].name} #{args[:prep]} what?".capitalize
  end
end

## SPECIAL ACTIONS
class Halt < Action
  def act(args)
    exit
  end
end

