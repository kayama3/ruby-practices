# frozen_string_literal: true

require_relative 'file_paths_collector'
require_relative 'short_formatter'
require_relative 'long_formatter'

module LS
  class Command
    def initialize(dotmatch: false, reverse: false, long_format: false)
      @file_paths = FilePathsCollector.new(dotmatch, reverse)
      @long_format = long_format
    end

    def exec
      short_paths = ShortFormatter.new(@file_paths.collect)
      long_paths = LongFormatter.new(@file_paths.collect)
      @long_format ? long_paths.list : short_paths.list
    end
  end
end
