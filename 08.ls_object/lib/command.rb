# frozen_string_literal: true

require_relative 'path'

module LS
  class Command
    TYPE_TABLE = {
      '01' => 'p',
      '02' => 'c',
      '04' => 'd',
      '06' => 'b',
      '10' => '-',
      '12' => 'l',
      '14' => 's'
    }.freeze

    MODE_TABLE = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }.freeze

    HALF_YEAR = 15_768_000

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
      file_stat = path.stat
      file_mode = path.mode
      {
        blocks: file_stat.blocks,
        type: TYPE_TABLE[file_mode[0..1]],
        mode: format_mode(file_mode),
        nlink: file_stat.nlink.to_s,
        user: Etc.getpwuid(file_stat.uid).name,
        group: Etc.getgrgid(file_stat.gid).name,
        size: file_stat.size.to_s,
        mtime: format_mtime(file_stat),
        name: path.name
      }
    end

    def format_mode(file_mode)
      # file_modeの３桁目（特殊権限の値）に応じて、rwx文字列を変化させる
      user_permission = change_user_permission
      group_permission = change_group_permission
      other_permission = change_other_permission
      [
        user_permission,
        group_permission,
        other_permission
      ].join
    end

    def change_user_permission(file_mode)
      if file_mode[2] == '4'
        MODE_TABLE[file_mode[3]].sub(/[x|-]$/, 'x' => 's', '-' => 'S')
      else
        MODE_TABLE[file_mode[3]]
      end
    end

    def change_group_permission(file_mode)
      if file_mode[2] == '2'
        MODE_TABLE[file_mode[4]].sub(/[x|-]$/, 'x' => 's', '-' => 'S')
      else
        MODE_TABLE[file_mode[4]]
      end
    end

    def change_other_permission(file_mode)
      if file_mode[2] == '1'
        MODE_TABLE[file_mode[5]].sub(/[x|-]$/, 'x' => 't', '-' => 'T')
      else
        MODE_TABLE[file_mode[5]]
      end
    end

    def format_mtime(file_stat)
      # 更新日が半年以内かどうかによって表示を変える
      format = Time.now - HALF_YEAR < file_stat.mtime ? '%b %e %R' : '%b %e  %Y'
      file_stat.mtime.strftime(format)
    end

    def render_long_format_body(detailed_path_data)
      max_sizes = { nlink: nil, user: nil, group: nil, size: nil }
      max_sizes.each { |key, _value| find_max_size(detailed_path_data, key, max_sizes) }
      detailed_path_data.map { |data| format_row(data, max_sizes) }
    end

    def find_max_size(detailed_path_data, key, max_sizes)
      max_sizes[key] = detailed_path_data.map { |data| data[key].size }.max
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
      puts transpose_path_names(path_names).map(&:join)
    end

    def format_path_names(path_names)
      path_names.push(' ') while path_names.size % COLUMN_COUNT != 0
      max_path_name_count = path_names.map{ |path_name| count_size(path_name) }.max
      path_names.map{ |path_name| path_name + ' ' * (max_path_name_count - count_size(path_name)) + '  ' }
    end

    def count_size(path_name)
      path_name.length + path_name.chars.reject(&:ascii_only?).length
    end

    def transpose_path_names(path_names)
      spaced_path_names = format_path_names(path_names)
      row_count = (path_names.size.to_f / COLUMN_COUNT).ceil
      paths = spaced_path_names.each_slice(row_count).to_a
      paths.transpose
    end
  end
end
