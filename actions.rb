class Action
  def initialize(opts)
    @actor = opts[:actor]
  end
end

class BadAction < Action
  def act(args)
    puts "Unknwon action."
  end
end

class ActionLook < Action
  def act(targets)
    targets[:subject].is_looked_at
  end
end

class ActionGrab < Action
  def act(targets)
    (targets[:object] || @actor.right_hand).grab(targets[:subject])
  end
end

class ActionPunch < Action
  def act(targets)
    (targets[:object] || @actor.right_hand).punch(targets[:subject])
  end
end

class ActionAttack < Action
  def act(targets)
    (targets[:object] || @actor.right_hand).attack(targets[:subject])
  end
end

class ActionDrop < Action
  def act(targets)
    targets[:subject].is_dropped
  end
end
