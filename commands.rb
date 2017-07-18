class Command
  attr_reader :range
  def initialize
    @range = nil
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

  def is_dropped(*args)
    puts "You don't have any \"#{@name}\" to drop."
  end

  alias :is_attacked :complain
  alias :is_punched :complain
  alias :is_looked_at :complain
end

class BadItem < BadTarget
  def complain(*args)
    puts "You don't have any \"#{@name}\" at the ready"
  end

  alias :attack :complain
  alias :punch :complain
end

class Look < Command
  def initialize
    @action = :look
    @range = :everything
    @default_target = "room"
  end

  def run(args)
    target = args[:subject] || args[:player].room
    args[:player].send(@action, target)
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
    args[:player].send(@action, args[:subject], args[:object])
  end
end

class Drop < Command
  def initialize
    @action = :drop
    @range = :hands
  end

  def run(args)
    args[:player].send(@action, args[:subject])
  end
end

class Grab < Command
  def initialize
    @action = :grab
    @range = :room
  end

  def run(args)
    args[:player].send(@action, args[:subject], args[:object])
  end
end

class Punch < Command
  def initialize
    @action = :punch
    @range = :room
  end

  def run(args)
    args[:player].send(@action, args[:subject], args[:object])
  end
end

