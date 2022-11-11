# /usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'optparse'

def main
  params = ARGV.getopts('l')
  params['l'] ? output_with_option_l : output
end

def input
  Dir.glob('*')
end

def output
  current_directory = input
  current_directory << ' ' while current_directory.size % 3 != 0
  max_number_of_columns = current_directory.size / 3
  data = []
  current_directory.each_slice(max_number_of_columns) { |n| data << n }

  results = data.transpose.flatten
  space = current_directory.map(&:size).max

  count = 0
  results.each do |n|
    count += 1
    print n.ljust(space + 2)
    print "\n" if (count % 3).zero?
  end
end

def blocks(current_directory)
  total_blocks = 0
  current_directory.each { |data| total_blocks += File.lstat(data).blocks }
  puts "total #{total_blocks}"
end

def fyle_type(results, file_mode)
  fyle_type = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
  results << fyle_type[file_mode[0..1]] # ファイルタイプの出力
end

def permission(results, file_mode)
  permission = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
  count = 0

  file_mode[3, 3].each_char do |char| # パーミッションの出力
    count += 1
    results << if file_mode[2] == '4' && count == 1
                 permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
               elsif file_mode[2] == '2' && count == 2
                 permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
               elsif file_mode[2] == '1' && count == 3
                 permission[char].sub(/x$|-$/, 'x' => 't', '-' => 'T')
               else
                 permission[char]
               end
  end
end

def nlink(spaces, results, file_stat)
  nlink = file_stat.nlink.to_s.rjust(spaces[:nlink_space] + 2)
  results << nlink
end

def user_name(spaces, results, file_stat)
  user_name = Etc.getpwuid(file_stat.uid).name.rjust(spaces[:user_name_space] + 1)
  results << user_name
end

def group_name(spaces, results, file_stat)
  group_name = Etc.getgrgid(file_stat.gid).name.rjust(spaces[:group_name_space] + 2)
  results << group_name
end

def file_size(spaces, results, file_stat)
  size = file_stat.size.to_s.rjust(spaces[:file_size_space] + 2)
  results << size
end

def update_time(results, file_stat)
  half_year = (60 * 60 * 24 * 182.5)
  time = Time.now - half_year < file_stat.mtime ? file_stat.mtime.strftime('%b %e %R') : file_stat.mtime.strftime('%b %e  %Y')
  results << " #{time}"
end

def file_name(results, data)
  results << " #{data}"
end

def kinds_of_spaces(current_directory, spaces)
  nlinks = []
  user_names = []
  group_names = []
  file_sizes = []

  current_directory.each do |data|
    file_stat = File.lstat(data)

    spaces[:nlink_space] = nlinks.map(&:size).max
    spaces[:user_name_space] = user_names.map(&:size).max
    spaces[:group_name_space] = group_names.map(&:size).max
    spaces[:file_size_space] = file_sizes.map(&:size).max

    nlinks << file_stat.nlink.to_s
    user_names << Etc.getpwuid(file_stat.uid).name
    group_names << Etc.getgrgid(file_stat.gid).name
    file_sizes << file_stat.size.to_s
  end
end

def output_with_option_l
  current_directory = input
  spaces = {}
  results = []

  kinds_of_spaces(current_directory, spaces)
  blocks(current_directory)

  current_directory.each do |data|
    file_stat = File.lstat(data)
    file_mode = file_stat.mode.to_s(8)
    file_mode.insert(0, '0') if file_mode.size == 5

    fyle_type(results, file_mode)
    permission(results, file_mode)
    nlink(spaces, results, file_stat)
    user_name(spaces, results, file_stat)
    group_name(spaces, results, file_stat)
    file_size(spaces, results, file_stat)
    update_time(results, file_stat)
    file_name(results, data)
  end

  results.each_slice(10) { |n| puts n.join }
end

main
