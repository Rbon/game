class Action
  def initialize(opts)
    @entity = opts[:entity]
    @subject = opts[:subject]
    @object = opts[:object]
  end
end

class BadAction < Action
  def act(args)
    puts "Unknown action."
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

class ActorGrab < Action
  def act(args)
    (args[:object] || @entity.right_hand).grab(args[:subject])
  end
end

class ActorPunch < Action
  def act(args)
    (args[:object] || @entity.right_hand).act(action: :punch, args: args)
  end
end

class ActorAttack < Action
  def act
    puts "ACTOR ATTACKING"
    @entity.right_hand.act(
      action: :attack,
      subject: @subject,
      object: @object
    )
  end
end

class WeaponAttack < Action
  def act
    puts "WEAPON ATTACKING"
    @subject.react(
      action: :attack,
      actor: @entity
    )
  end
end

class ActorDrop < Action
  def act(args)
    targets[:subject].is_dropped
  end
end

class ActorStash < Action
  def act(args)
    @actor.backpack.stash(args[:subject])
  end
end

class ActorUnstash < Action
  def act(args)
    @actor.backpack.unstash(args[:subject])
  end
end

class Halt < Action
  def act(args)
    exit
  end
end

class ItemCannotAttack < Action
  def act(args)
    puts "You cannot attack with #{@entity.name}."
  end
end

class Reaction
  def initialize(opts)
    @entity = opts[:entity]
    @actor = opts[:actor]
  end
end

class LookReaction < Reaction
  def act
    puts "You look longingly at the #{@entity.name}."
  end
end

class AttackReaction < Reaction
  def act
    puts "You attack the #{@entity.name}."
    @entity.is_damaged(@actor.attacking_with.attack_damage)
  end
end
