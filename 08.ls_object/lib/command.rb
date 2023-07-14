# frozen_string_literal: true

require_relative 'path'

COLUMN_NUMBER = 3

module LS
  class Command
    def initialize(dotmatch: false, reverse: false, long_format: false)
      @dotmatch = dotmatch
      @reverse = reverse
      @long_format = long_format
    end

    def exec
      file_paths = collect_paths
      path_data = file_paths.each.with_object([]) { |file_path, n| n << Path.new(file_path) }
      @long_format ? list_long(path_data) : list_short(path_data)
    end

    private

    def collect_paths
      file_paths = @dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
      @reverse ? file_paths.reverse : file_paths
    end

    # lオプションあり
    def list_long(path_data)
      row_data = path_data.map(&:build_data)
      blocks = row_data.sum { |data| data[:blocks] }
      total = "total #{blocks}"
      body = render_long_format_body(row_data)
      puts [total, *body].join("\n")
    end

    def render_long_format_body(row_data)
      max_sizes = %i[nlink user group size].map do |key|
        find_max_size(row_data, key)
      end
      row_data.map do |data|
        format_row(data, *max_sizes)
      end
    end

    def find_max_size(row_data, key)
      row_data.map { |data| data[key].size }.max
    end

    def format_row(data, max_nlink, max_user, max_group, max_size)
      [
        data[:type],
        data[:mode],
        "  #{data[:nlink].rjust(max_nlink)}",
        " #{data[:user].ljust(max_user)}",
        "  #{data[:group].ljust(max_group)}",
        "  #{data[:size].rjust(max_size)}",
        " #{data[:mtime]}",
        " #{data[:name]}"
      ].join
    end

    # lオプションなし
    def list_short(path_data)
      path_name = path_data.map(&:name)
      result = transpose_file_paths(path_name).map { |n| n.push("\n").join }
      puts result
    end

    def format_file_paths(path_name)
      path_name.push(' ') while path_name.size % COLUMN_NUMBER != 0
      max_file_path_count = path_name.map(&:size).max
      path_name.map { |n| n.ljust(max_file_path_count + 2) }
    end

    def transpose_file_paths(path_name)
      spaced_file_paths = format_file_paths(path_name)
      max_number_of_rows = (path_name.size / COLUMN_NUMBER).ceil
      paths = spaced_file_paths.each_slice(max_number_of_rows).with_object([]) { |n, m| m << n }
      paths.transpose
    end
  end
end
