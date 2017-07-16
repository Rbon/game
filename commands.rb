class Command
  attr_reader :range
  def find_target(args)
    args[:target_list].flatten.each do |entity|
      return entity if entity.name == args[:target_name]
    end
    false
  end

  def bad_target(target_name)
    puts "Unknown #{@action} target: #{target_name}"
  end

  def run(args)
    if @default_target
      args[:target_name] = @default_target unless target
    end
    target = find_target(args)
    if target
      args[:actor].send(@action, target)
    else
      bad_target(args[:target_name])
    end
  end
end

class BadCommand
  def initialize(command_name)
    @command_name = command_name
  end

  def run(args)
    puts "Unknown command: #{@command_name}"
  end
end

class Look < Command
  def initialize
    @action = :look
    @range = :everything
    @default_target = "room"
  end
end

class Halt
  def run(junk, more_junk)
    exit
  end
end

class Attack < Command
  def initialize
    @action = :attack
    @range = :room
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

