class Action
  def initialize(opts)
    @entity = opts[:entity]
    @subject = opts[:subject]
    @object = opts[:object]
  end
end

class BadAction < Action
  def act
    puts "Unknown action."
  end
end

class ActorAttack < Action
  def act
    @entity.right_hand.act(
      action: :attack,
      subject: @subject,
      object: @object
    )
  end
end

class ActorDrop < Action
  def act
    @entity.right_hand.act(
      action: :drop,
      subject: @subject,
      object: @object
    )
  end
end

class ActorGrab < Action
  def act
    @entity.right_hand.act(
      action: :grab,
      subject: @subject,
      object: @object
    )
  end
end

class ActorLook < Action
  def act
    @subject.react(
      action: :look,
      actor: @entity
    )
  end
end

class ActorPunch < Action
  def act
    @entity.right_hand.act(
      action: :punch,
      subject: @subject,
      object: @object
    )
  end
end

class WeaponAttack < Action
  def act
    @entity.owner.attacking_with = @entity
    @subject.react(
      action: :attack,
      actor: @entity.owner
    )
  end
end

class ActorStash < Action
  def act
    @entity.backpack.act(
      action: :stash,
      subject: @subject,
      object: @object
    )
  end
end

class ActorUnstash < Action
  def act
    puts "ACTOR UNSTASHING"
    @entity.backpack.act(
      action: :unstash,
      subject: @subject,
      object: @object
    )
  end
end

class ItemCannotAttack < Action
  def act
    puts "You cannot attack with #{@entity.name}."
  end
end

class FistAttack < Action
  def act
    if @entity.entity_list.empty?
      @entity.owner.attacking_with = @entity
      @subject.react(
        action: :punch,
        actor: @entity.owner
      )
    else
      @entity.owner.attacking_with = @entity.entity_list[0]
      @entity.entity_list[0].act(
        action: :attack,
        subject: @subject
      )
    end
    @entity.owner.attacking_with = nil
  end
end

class FistDrop < Action
  def act
    @entity.owner.grabbing_with = @entity
    @subject.react(
      action: :drop,
      actor: @entity.owner
    )
  end
end

class FistGrab < Action
  def act
    @entity.owner.grabbing_with = @entity
    @subject.react(
      action: :grab,
      actor: @entity.owner
    )
  end
end

class BackpackStash < Action
  def act
    @subject.react(
      action: :stash,
      actor: @entity.owner
    )
  end
end

class BackpackUnstash < Action
  def act
    puts "BACKPACK UNSTASHING"
    @subject.react(
      action: :unstash,
      actor: @entity.owner
    )
  end
end

## REACTIONS
class Reaction
  def initialize(opts)
    @entity = opts[:entity]
    @actor = opts[:actor]
  end
end

class AttackReaction < Reaction
  def act
    puts "You attack the #{@entity.name}."
    @entity.react(
      action: :damage,
      amount: @actor.attacking_with.attack_damage
    )
  end
end

class DropReaction < Reaction
  def act
    @entity.container.entity_list.delete(@entity)
    @entity.room.entity_list.push(@entity)
    @entity.container.free_space += @entity.volume
    @entity.container = nil
    puts "You drop the #{@entity.name} on the floor."
  end
end

class DamageReaction < Reaction
  def initialize(opts)
    super
    @amount = opts[:amount]
  end

  def act
    puts "The #{@entity.name} takes #{@amount} damage. [#{@entity.hp} -> #{@entity.hp - @amount}]"
    @entity.hp -= @amount
  end
end

class GrabReaction < Reaction
  def act
    @entity.container = @actor.grabbing_with
    @entity.owner = @actor
    @entity.room.entity_list.delete(@entity)
    @entity.container.entity_list.push(@entity)
    puts "You grab the #{@entity.name} with your #{@entity.owner.grabbing_with.name}."
  end
end

class LookReaction < Reaction
  def act
    puts "You look longingly at the #{@entity.name}."
  end
end

class PunchReaction < Reaction
  def act
    puts "You punch the #{@entity.name}."
    @entity.react(
      action: :damage,
      amount: @actor.attacking_with.attack_damage
    )
  end
end

class PunchSelf < Reaction
  def act
    puts "You punch yourself."
  end
end

class PlayerLookReaction < Reaction
  def act
    @entity.left_hand.is_looked_at
    @entity.right_hand.is_looked_at
    @entity.backpack.is_looked_at
  end
end

class SwordPunchReaction < Reaction
  def act
    puts "You punch the sword."
    puts "The sword takes no damage."
    puts "You hurt your fist punching a sword."
    puts "You take 1 damage [#{@actor.hp} -> #{@actor.hp - 1}]"
    @actor.hp -= 1
  end
end

class FistLookReaction < Reaction
  def act
    if @entity.entity_list.empty?
      puts "There is nothing in your #{@entity.name}."
    else
      puts "In your right hand, you are holding a #{@entity.entity_list[0].name}"
    end
  end
end

class ItemStashReaction < Reaction
  def act
    @actor.right_hand.entity_list.delete(@entity)
    @actor.backpack.entity_list.push(@entity)
    puts "You stash the #{@entity.name} in your backpack."
  end
end

class ItemUnstashReaction < Reaction
  def act
    puts "ITEM REACTING TO UNSTASH"
    @actor.backpack.entity_list.delete(@entity)
    @actor.right_hand.entity_list.push(@entity)
    puts "You grab the #{@entity.name} from your backpack."
  end
end

## SPECIAL ACTIONS
class Halt < Action
  def act
    exit
  end
end

