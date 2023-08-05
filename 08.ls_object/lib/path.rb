# frozen_string_literal: true

module LS
  class Path
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def stat
      File.lstat(@name)
    end

    def mode
      file_mode = stat.mode.to_s(8)
      file_mode.insert(0, '0') if file_mode.size == 5
      file_mode
    end
  end
end
