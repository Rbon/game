class Command
  def find_target(target_name)
    @range.flatten.each do |entity|
      return entity if entity.name == target_name
    end
    false
  end

  def bad_target(target_name)
    puts "Unknown #{@action} target: #{target_name}"
  end
end

class BadCommand
  def initialize(command_name)
    @command_name = command_name
  end

  def run(junk, more_junk)
    puts "Unknown command: #{@command_name}"
  end
end

class Look < Command
  def initialize(opts)
    @range = opts[:range]
    @action = :look
  end

  def run(actor, target_name)
    if target_name
      target = find_target(target_name)
    else
      target = actor.room
    end
    if target
      puts target.look_text
    else
      bad_target(target_name)
    end
  end
end

class Halt
  def run(junk, more_junk)
    exit
  end
end

class PlayerAction < Command
  def initialize(opts)
    @range = opts[:range]
    @target_name = opts[:target_name]
    @actor = opts[:actor]
    @action = opts[:action]
  end

  def run(actor, target_name)
    if target_name
      target = find_target(target_name)
    end
    if target
      actor.send(@action, target)
    else
      bad_target(target_name)
    end
  end
end

class Test
  def initialize(thing)
    @thing = thing
  end

  def run(junk, more_junk)
    puts @thing
  end
end

