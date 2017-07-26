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

class Stash < Command
  def initialize
    @action = :stash
    @range = :held
  end
  def run(args)
    args[:player].send(@action, args[:subject])
  end
end

class Unstash < Command
  def initialize
    @action = :unstash
    @range = :backpack
  end

  def run(args)
    args[:player].send(@action, args[:subject])
  end
end
