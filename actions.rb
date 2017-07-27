class BadAction
  def act(args)
    puts "Unknown action: #{args[:action]}"
  end
end

class PassToHand
  def act(args)
    args[:tool] ||= args[:actor].right_hand
    args[:tool].act(args)
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

class Attack
  def act(args)
    puts "You attack the #{args[:target].name} with your #{args[:tool].name}."
    args.update(
      action: :damage,
      amount: args[:tool].damage
    )
    args[:target].react(args)
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
class NullAttack
  def act
    puts "There is no \"#{@entity.name}\" to attack here."
  end
end

class NullDrop
  def act
    puts "You aren't holding any \"#{@entity.name}\"."
  end
end

class NullGrab
  def act
    puts "There is no \"#{@entity.name}\" to grab here."
  end
end

class NullLook
  def act
    puts "You don't see any \"#{@entity.name}\" here."
  end
end

class NullPunch
  def act
    puts "There is no \"#{@entity.name}\" to punch here."
  end
end

class NullStash
  def act
    puts "You aren't holding any \"#{@entity.name}\"."
  end
end

class NullUnstash
  def act
    puts "There is no \"#{@entity.name}\" in your backpack."
  end
end

## SPECIAL ACTIONS
class Halt
  def act(args)
    exit
  end
end

