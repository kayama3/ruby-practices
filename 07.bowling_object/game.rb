# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(score)
    @score = score
  end

  def parse_scores
    scores = @score.split(',')
    frames = []
    9.times do
      frame = scores.shift(2)
      frame << scores[0]

      if frame.first == 'X'
        frames << frame
        scores.unshift(frame[1])
      else
        frames << frame
      end
    end
    frames << scores
  end

  def score
    game_scores = []
    frames = parse_scores
    frames.each do |frame|
      new_frame = Frame.new(frame[0], frame[1], frame[2])
      game_scores << new_frame.score
    end
    game_scores.sum
  end
end

game = Game.new(ARGV[0])
puts game.score
