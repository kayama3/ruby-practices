# frozen_string_literal: true

COLUMN_NUMBER = 3

class ShortFormatter
  def initialize(file_paths)
    @file_paths = file_paths
  end

  def list
    result = transpose_file_paths.map { |n| n.push("\n").join }
    puts result
  end

  private

  def format_file_paths
    @file_paths.push(' ') while @file_paths.size % COLUMN_NUMBER != 0
    max_file_path_count = @file_paths.map(&:size).max
    @file_paths.map { |n| n.ljust(max_file_path_count + 2) }
  end

  def transpose_file_paths
    spaced_file_paths = format_file_paths
    max_number_of_rows = (@file_paths.size / COLUMN_NUMBER).ceil
    paths = spaced_file_paths.each_slice(max_number_of_rows).with_object([]) { |n, m| m << n }
    paths.transpose
  end
end
