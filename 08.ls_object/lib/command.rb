# frozen_string_literal: true

require_relative 'path'

module LS
  class Command
    COLUMN_COUNT = 3.0

    def initialize(dotmatch: false, reverse: false, long_format: false)
      @dotmatch = dotmatch
      @reverse = reverse
      @long_format = long_format
    end

    def exec
      sorted_paths = sort_paths
      path_data = sorted_paths.map { |path| Path.new(path) }
      @long_format ? list_long(path_data) : list_short(path_data)
    end

    private

    def sort_paths
      collected_paths = collect_paths
      @reverse ? collected_paths.reverse : collected_paths
    end

    def collect_paths
      @dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def list_long(path_data)
      detailed_path_data = path_data.map { |path| build_data(path) }
      blocks = detailed_path_data.sum { |data| data[:blocks] }
      total = "total #{blocks}"
      body = render_long_format_body(detailed_path_data)
      puts [total, *body].join("\n")
    end

    def build_data(path)
      {
        blocks: path.blocks,
        type: path.type,
        mode: path.mode,
        nlink: path.nlink,
        user: path.user,
        group: path.group,
        size: path.size,
        mtime: path.mtime,
        name: path.name
      }
    end

    def render_long_format_body(detailed_path_data)
      max_sizes = find_max_size(detailed_path_data)
      detailed_path_data.map { |data| format_row(data, max_sizes) }
    end

    def find_max_size(detailed_path_data)
      max_sizes = { nlink: nil, user: nil, group: nil, size: nil }
      max_sizes.each do |key, _value|
        max_sizes[key] = detailed_path_data.map { |data| data[key].size }.max
      end
    end

    def format_row(data, max_sizes)
      [
        data[:type],
        data[:mode],
        "  #{data[:nlink].rjust(max_sizes[:nlink])}",
        " #{data[:user].ljust(max_sizes[:user])}",
        "  #{data[:group].ljust(max_sizes[:group])}",
        "  #{data[:size].rjust(max_sizes[:size])}",
        " #{data[:mtime]}",
        " #{data[:name]}"
      ].join
    end

    def list_short(path_data)
      path_names = path_data.map(&:name)
      paths = format_path_names(path_names)
      puts paths.transpose.map(&:join)
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
      path_name.length + path_name.chars.reject(&:ascii_only?).length
    end
  end
end
