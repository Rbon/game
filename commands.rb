class Command
  attr_reader :range
  def initialize
    @range = nil
  end

  def check
    true
  end

  def run(args)
    if @default_target
      args[:target_name] = @default_target unless args[:target_name]
    end
    target = find_target(args)
    if target
      args[:actor].send(@action, target)
    else
      bad_target(args[:target_name])
    end
  end
end

class BadCommand < Command
  def initialize(command_name)
    @command_name = command_name
  end

  def run(*args)
    puts "Unknown command: #{@command_name}"
  end
end

class BadTarget
  def initialize(opts)
    @name = opts
  end

  def complain(*args)
    puts "You don't see any \"#{@name}\" here."
  end

  alias :is_attacked :complain
  alias :is_punched :complain
end

class BadItem < BadTarget
  def check
    puts "You don't have any \"#{@name}\" at the ready"
    false
  end
end

class Look < Command
  def initialize
    @action = :look
    @range = :everything
    @default_target = "room"
  end
end

class Halt < Command
  def run(*args)
    exit
  end
end

class Attack < Command
  def initialize
    @action = :attack
    @range = :room
  end

  def run(args)
    args[:player].send(@action, args[:subject])
  end
end

class Drop < Command
  def initialize
    @action = :drop
    @range = :held
  end
end

class Grab < Command
  def initialize
    @action = :grab
    @range = :room
  end
end

class Punch < Command
  def initialize
    @action = :punch
    @range = :room
  end
end

