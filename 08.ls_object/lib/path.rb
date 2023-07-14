# frozen_string_literal: true

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

class Path
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def build_data
    file_stat = File.lstat(@name)
    file_mode = file_stat.mode.to_s(8)
    file_mode.insert(0, '0') if file_mode.size == 5
    {
      blocks: file_stat.blocks,
      type: TYPE_TABLE[file_mode[0..1]],
      mode: format_mode(file_mode),
      nlink: file_stat.nlink.to_s,
      user: Etc.getpwuid(file_stat.uid).name,
      group: Etc.getgrgid(file_stat.gid).name,
      size: file_stat.size.to_s,
      mtime: format_mtime(file_stat),
      name: @name
    }
  end

  private

  def format_mode(file_mode)
    # file_modeの３桁目（特殊権限の値）に応じて、rwx文字列を変化させる
    [
      file_mode[2] == '4' ? MODE_TABLE[file_mode[3]].sub(/x$|-$/, 'x' => 's', '-' => 'S') : MODE_TABLE[file_mode[3]],
      file_mode[2] == '2' ? MODE_TABLE[file_mode[4]].sub(/x$|-$/, 'x' => 's', '-' => 'S') : MODE_TABLE[file_mode[4]],
      file_mode[2] == '1' ? MODE_TABLE[file_mode[5]].sub(/x$|-$/, 'x' => 't', '-' => 'T') : MODE_TABLE[file_mode[5]]
    ].join
  end

  def format_mtime(file_stat)
    # 更新日が半年以内かどうかによって表示を変える
    Time.now - HALF_YEAR < file_stat.mtime ? file_stat.mtime.strftime('%b %e %R') : file_stat.mtime.strftime('%b %e  %Y')
  end
end
