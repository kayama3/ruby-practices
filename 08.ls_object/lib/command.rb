# frozen_string_literal: true

require_relative 'path'

module LS
  class Command
    COLUMN_COUNT = 3

    def initialize(dotmatch: false, reverse: false, long_format: false)
      @dotmatch = dotmatch
      @reverse = reverse
      @long_format = long_format
    end

    def exec
      paths = collect_paths
      sorted_paths = @reverse ? paths.reverse : paths
      path_objects = sorted_paths.map { |path| Path.new(path) }
      @long_format ? list_long(path_objects) : list_short(path_objects)
    end

    private

    def collect_paths
      @dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def list_long(path_objects)
      blocks = path_objects.sum(&:blocks)
      total = "total #{blocks}"
      body = build_long_format_body(path_objects)
      puts [total, *body]
    end

    def build_long_format_body(path_objects)
      max_sizes = find_max_sizes(path_objects)
      path_objects.map { |path| format_row(path, max_sizes) }
    end

    def find_max_sizes(path_objects)
      {
        nlink: path_objects.map(&:nlink).max.to_s.length,
        user: path_objects.map(&:user).max.length,
        group: path_objects.map(&:group).max.length,
        size: path_objects.map(&:size).max.to_s.length
      }
    end

    def format_row(path, max_sizes)
      [
        path.type,
        path.mode,
        "  #{path.nlink.to_s.rjust(max_sizes[:nlink])}",
        " #{path.user.ljust(max_sizes[:user])}",
        "  #{path.group.ljust(max_sizes[:group])}",
        "  #{path.size.to_s.rjust(max_sizes[:size])}",
        " #{path.mtime}",
        " #{path.name}"
      ].join
    end

    def list_short(path_objects)
      path_names = path_objects.map(&:name)
      formatted_path_names = format_path_names(path_names)
      puts formatted_path_names.transpose.map(&:join)
    end

    def format_path_names(path_names)
      path_names.push('') while path_names.length % COLUMN_COUNT != 0
      justified_path_names = left_justify_path_names(path_names)
      row_count = (path_names.length.to_f / COLUMN_COUNT).ceil
      justified_path_names.each_slice(row_count).to_a
    end

    def left_justify_path_names(path_names)
      max_path_name_count = path_names.map { |path_name| path_name.length + count_full_byte(path_name) }.max
      path_names.map do |path_name|
        padding_size = max_path_name_count - count_full_byte(path_name) + 2
        path_name.ljust(padding_size)
      end
    end

    def count_full_byte(path_name)
      path_name.chars.count { |string| !string.ascii_only? }
    end
  end
end
