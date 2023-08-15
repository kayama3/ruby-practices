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
      collected_paths = collect_paths
      sorted_paths = sort_paths(collected_paths)
      paths = sorted_paths.map { |path| Path.new(path) }
      @long_format ? list_long(paths) : list_short(paths)
    end

    private

    def sort_paths(collected_paths)
      @reverse ? collected_paths.reverse : collected_paths
    end

    def collect_paths
      @dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def list_long(paths)
      blocks = paths.sum { |path| path.blocks }
      total = "total #{blocks}"
      body = render_long_format_body(paths)
      puts [total, *body]
    end

    def render_long_format_body(paths)
      max_sizes = find_max_sizes(paths)
      paths.map { |path| format_row(path, max_sizes) }
    end

    def find_max_sizes(paths)
      {
        nlink: paths.map { |path| path.nlink.size }.max,
        user: paths.map { |path| path.user.size }.max,
        group: paths.map { |path| path.group.size }.max,
        size: paths.map { |path| path.size.size }.max
      }
    end

    def format_row(path, max_sizes)
      [
        path.type,
        path.mode,
        "  #{path.nlink.rjust(max_sizes[:nlink])}",
        " #{path.user.ljust(max_sizes[:user])}",
        "  #{path.group.ljust(max_sizes[:group])}",
        "  #{path.size.rjust(max_sizes[:size])}",
        " #{path.mtime}",
        " #{path.name}"
      ].join
    end

    def list_short(paths)
      path_names = paths.map(&:name)
      transposed_path_names = transpose_path_names(path_names)
      puts transposed_path_names.map(&:join)
    end

    def transpose_path_names(path_names)
      formatted_path_names = format_path_names(path_names)
      formatted_path_names.transpose
    end

    def format_path_names(path_names)
      path_names.push(' ') while path_names.size % COLUMN_COUNT != 0
      justified_path_names = left_justify_path_names(path_names)
      row_count = (path_names.size.to_f / COLUMN_COUNT).ceil
      justified_path_names.each_slice(row_count).to_a
    end

    def left_justify_path_names(path_names)
      max_path_name_count = path_names.map { |path_name| count_path_sizes(path_name) }.max
      path_names.map { |path_name| "#{path_name + ' ' * (max_path_name_count - count_path_sizes(path_name))}  " }
    end

    def count_path_sizes(path_name)
      path_name.length + path_name.chars.count { |string| string.ascii_only? == false }
    end
  end
end
