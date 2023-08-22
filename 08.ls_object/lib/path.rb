# frozen_string_literal: true

module LS
  class Path
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

    attr_reader :name

    def initialize(name)
      @name = name
      @file_stat = File.lstat(@name)
      @file_mode = file_mode
    end

    def blocks
      @file_stat.blocks
    end

    def type
      TYPE_TABLE[@file_mode[0..1]]
    end

    def mode
      user_permission = find_user_permission
      group_permission = find_group_permission
      other_permission = find_other_permission
      [
        user_permission,
        group_permission,
        other_permission
      ].join
    end

    def nlink
      @file_stat.nlink
    end

    def user
      Etc.getpwuid(@file_stat.uid).name
    end

    def group
      Etc.getgrgid(@file_stat.gid).name
    end

    def size
      @file_stat.size
    end

    def mtime
      @file_stat.mtime
    end

    private

    def file_mode
      file_mode = @file_stat.mode.to_s(8)
      file_mode.rjust(6, '0')
    end

    def find_user_permission
      find_permission(3, '4', 'sS')
    end

    def find_group_permission
      find_permission(4, '2', 'sS')
    end

    def find_other_permission
      find_permission(5, '1', 'tT')
    end

    def find_permission(mode_index, permission_type, character)
      permission = MODE_TABLE[@file_mode[mode_index]]
      if @file_mode[2] == permission_type
        permission[0, 2] + permission[2].tr('x-', character)
      else
        permission
      end
    end
  end
end
