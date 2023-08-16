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

    HALF_YEAR = 15_768_000

    attr_reader :name

    def initialize(name)
      @name = name
      @stat = file_stat
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
      # 更新日が半年以内かどうかによって表示を変える
      format = Time.now - HALF_YEAR < @stat.mtime ? '%b %e %R' : '%b %e  %Y'
      @stat.mtime.strftime(format)
    end

    private

    def file_stat
      File.lstat(@name)
    end

    def file_mode
      file_mode = @stat.mode.to_s(8)
      file_mode.rjust(6, '0')
    end

    def check_suid
      if @mode[2] == '4'
        MODE_TABLE[@mode[3]].sub(/[x|-]$/, 'x' => 's', '-' => 'S')
      else
        MODE_TABLE[@mode[3]]
      end
    end

    def check_sgid
      if @mode[2] == '2'
        MODE_TABLE[@mode[4]].sub(/[x|-]$/, 'x' => 's', '-' => 'S')
      else
        MODE_TABLE[@mode[4]]
      end
    end

    def check_sticky_bit
      if @mode[2] == '1'
        MODE_TABLE[@mode[5]].sub(/[x|-]$/, 'x' => 't', '-' => 'T')
      else
        MODE_TABLE[@mode[5]]
      end
    end
  end
end
