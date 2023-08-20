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
      @stat = File.lstat(@name)
      @mode = file_mode
    end

    def blocks
      @stat.blocks
    end

    def type
      TYPE_TABLE[@mode[0..1]]
    end

    def mode
      user_permission = check_suid
      group_permission = check_sgid
      other_permission = check_sticky_bit
      [
        user_permission,
        group_permission,
        other_permission
      ].join
    end

    def nlink
      @stat.nlink
    end

    def user
      Etc.getpwuid(@stat.uid).name
    end

    def group
      Etc.getgrgid(@stat.gid).name
    end

    def size
      @stat.size
    end

    def mtime
      @stat.mtime
    end

    private

    def file_mode
      file_mode = @stat.mode.to_s(8)
      file_mode.rjust(6, '0')
    end

    def check_suid
      permission = MODE_TABLE[@mode[3]]
      if @mode[2] == '4'
        permission[0, 2] + permission[2].tr('x-', 'sS')
      else
        permission
      end
    end

    def check_sgid
      permission = MODE_TABLE[@mode[4]]
      if @mode[2] == '2'
        permission[0, 2] + permission[2].tr('x-', 'sS')
      else
        permission
      end
    end

    def check_sticky_bit
      permission = MODE_TABLE[@mode[5]]
      if @mode[2] == '1'
        permission[0, 2] + permission[2].tr('x-', 'tT')
      else
        permission
      end
    end
  end
end
