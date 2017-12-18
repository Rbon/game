class Actor
  def initialize(current_room)
    @current_room = current_room
    @current_room.push(self)
    @hp = 100
  end

  def attack(target)
    target.hp -= 10
  end
end

class User
  def initialize(actor)
    @actor = actor
  end

  def attack(target)
    @actor.attack(target)
  end

  def halt
    exit
  end
end

class Main
  def initialize
    @room = []
    @human = Actor.new(@room)
    @orc = Actor.new(@room)
    @user = User.new(@human)
  end

  def run
    loop do
      parse(gets.chomp)
    end
  end

  def parse(input)
    action, target = input.split
    @user.send(action, target)
  end
end
