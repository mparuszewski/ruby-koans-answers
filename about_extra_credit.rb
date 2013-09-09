# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

class Game

  def initialize(players)
    fail "This game needs 2 or more players" unless players.is_a?(Fixnum) or players < 2

    @players = []
    players.times {|n| @players << Player.new("Player #{n+1}") }
    
    printf "-- New game has been created. #{players} players will play. --\n\n"

  end

  def start
    until self.finalround?
      @players.each { |player| player.turn }
    end

    printf "\n-- Time for final round! --\n\n"

    @players.each { |player| player.turn }

    printf "---- And the winner is #{winner.name} with #{winner.points}. ----\n\n"

    i = 1

    printf "Place | Player Name | Points\n"
    @players.sort_by { |player| player.points }.reverse_each do |player| 
      printf "%5d | %11s | %s\n" % [i, player.name, player.points]
      i += 1
    end

  end

  def self.roll(n)
    values = []
    n.times { values << 1 + rand(6) }
    
    values
  end

  def self.score(dice)
    result = 0
    scoring_dices = 0

    three = dice.uniq.select { |n| n != 1 && dice.count(n) >= 3 }

    if dice.count(1) >= 3
      result += 1000
      [1, 1, 1].each { |n| dice.delete_at(dice.index(n)) }
      scoring_dices += 3
    end
    unless three.empty?
      three.each do |n| 
        result += 100 * n
        [n, n, n].each { |n| dice.delete_at(dice.index(n)) }
        scoring_dices += 3
      end
    end
    if dice.count(1) > 0
      result += 100 * dice.count(1)
      scoring_dices += 1
    end
    if dice.count(5) > 0
      result += 50 * dice.count(5)
      scoring_dices += 1
    end

    [result, scoring_dices]

  end

  def finalround?
    @players.each { |player| return true if player.points >= 3000 }
    return false
  end

  def winner
    @players.max_by { |player| player.points }
  end

  class Player
    attr_reader :points, :name

    def initialize(name)
      @points = 0
      @name = name
    end

    def turn
      dices = scoring_dices = 5
      points_in_turn = 0
      
      printf "#{@name} turn:\n"

      until dices == 0
        result, scoring_dices = Game.score(Game.roll(dices))
        points_in_turn += result
        printf " #{result} points got in that roll.\n"

        if scoring_dices == 0
          printf "  Roll has zero points. All #{points_in_turn} points were lost.\n"
          
          points_in_turn = 0
          dices = 0
        elsif scoring_dices == dices
          dices = [true, false].sample ? 0 : 5
          printf "  Happy roll. All dices are scoring. Player decided to " + (dices == 0 ? "stop" : "play on") + ".\n"
        else
          string = "  Only #{scoring_dices} of #{dices} are scoring. Player decided to "
          dices -= scoring_dices
          
          unless [true, false].sample
            dices = 0
          end

          printf string + (dices == 0 ? "stop" : "play on") + ".\n"
        end
      end

      @points += points_in_turn if @points >= 300 || points_in_turn >= 300

      printf "   #{points_in_turn} got in that turn. #{@name} has now #{points}.\n\n"
    end

  end

end

Game.new(2).start