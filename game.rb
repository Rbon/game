class Main
  def initialize
    @player = Player.new
    @computer = Computer.new
    @commands = {
      rock: :rock,
      score: :display_score,
      quit: :halt
    }
  end

  def run
    puts(
      "Welcome!",
      'Commands are "rock", "paper", "scissors", and "quit",',
      'or "r", "p", "s", and "q" for short.'
    )
    loop do
      get_user_action
    end
  end

  def get_user_action
    print "\n > "
    @line = gets.chomp.split
    command = @commands[@line.to_sym] || :bad_command
    target = @targets[target]
  end

  def bad_command
    puts "Unknown command: #{@line}"
    get_user_action
  end

  def step(action, target)
    @player.send(action, target)
    @computer.take_turn
    check_results
    display_score
  end

  def equip(item)
    step(:euqip, item)
  end

  def rock
    step(:equip, Rock.new)
  end

  def paper
    step(:equip, Paper.new)
  end

  def scissors
    step(:equip, Scissors.new)
  end

  def halt
    exit
  end

  def check_results
    puts "You chose #{@player.right_hand.to_s}"
    puts "Computer chose #{@computer.right_hand.to_s}"
    self.send(@player.right_hand.versus(@computer.right_hand))
  end

  def display_score
    puts "Your score: #{@player.score}"
    puts "Computer score: #{@computer.score}"
  end

  def win
    puts "You win!"
    @player.score += 1
  end

  def loss
    puts "You lose!"
    @computer.score += 1
  end

  def draw
    puts "It's a draw!"
  end
end

class Player
  attr_reader :right_hand
  attr_accessor :score

  def initialize
    @score = 0
    @right_hand = nil
  end

  def equip(item)
    @right_hand = item
  end
end

class Computer < Player
  attr_reader :hand

  def take_turn
    equip([Rock, Paper, Scissors].sample.new)
  end
end

class Hand
  def versus(hand)
    @matchups[hand.to_s]
  end
end

class Rock < Hand
  attr_reader :matchups, :to_s

  def initialize
    @matchups = {
      rock: :draw,
      paper: :loss,
      scissors: :win
    }
    @to_s = :rock
  end

end

class Paper < Hand
  attr_reader :matchups, :to_s

  def initialize
    @matchups = {
      rock: :win,
      paper: :draw,
      scissors: :loss
    }
    @to_s = :paper
  end
end

class Scissors < Hand
  attr_reader :matchups, :to_s

  def initialize
    @matchups = {
      rock: :loss,
      paper: :win,
      scissors: :draw
    }
    @to_s = :scissors
  end
end

class BadHand < Hand
  def initialize

  end
end

Main.new.run
