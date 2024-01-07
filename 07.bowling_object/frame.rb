# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(first_mark, second_mark, third_mark)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
  end

  def score
    if @first_shot.score == 10 || @first_shot.score + @second_shot.score == 10
      @first_shot.score + @second_shot.score + @third_shot.score
    else
      @first_shot.score + @second_shot.score
    end
  end
end
