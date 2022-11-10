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
  current_directory.each { |n| total_blocks += File.lstat(n).blocks }
  puts "total #{total_blocks}"
end

def fyle_type(current_directory, data)
  fyle_type = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }

  current_directory.each do |n|
    fs = File.lstat(n)
    fs_mode = fs.mode.to_s(8)
    fs_mode.insert(0, '0') if fs_mode.size == 5
    data << fyle_type[fs_mode[0..1]] # ファイルタイプの出力
  end
end

def permission(current_directory, data)
  permission = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
  permission_data = []

  current_directory.each do |n|
    count = 0
    fs = File.lstat(n)
    fs_mode = fs.mode.to_s(8)
    fs_mode.insert(0, '0') if fs_mode.size == 5

    fs_mode[3, 3].each_char do |char| # パーミッションの出力
      count += 1
      permission_data << if fs_mode[2] == '4' && count == 1
                           permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
                         elsif fs_mode[2] == '2' && count == 2
                           permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
                         elsif fs_mode[2] == '1' && count == 3
                           permission[char].sub(/x$|-$/, 'x' => 't', '-' => 'T')
                         else
                           permission[char]
                         end
    end
  end
  permission_data.each_slice(3) { |n| data << n.join }
end

def nlink(current_directory, spaces, data)
  nlinks = []
  current_directory.each do |n|
    fs = File.lstat(n)
    nlinks << fs.nlink.to_s
  end
  spaces[:nlink_space] = nlinks.map(&:size).max

  current_directory.each do |n|
    fs = File.lstat(n)
    nlink = fs.nlink.to_s.rjust(spaces[:nlink_space] + 2)
    data << nlink
  end
end

def user_name(current_directory, spaces, data)
  user_names = []
  current_directory.each do |n|
    fs = File.lstat(n)
    user_names << Etc.getpwuid(fs.uid).name
  end
  spaces[:user_name_space] = user_names.map(&:size).max

  current_directory.each do |n|
    fs = File.lstat(n)
    user_name = Etc.getpwuid(fs.uid).name.rjust(spaces[:user_name_space] + 1)
    data << user_name
  end
end

def group_name(current_directory, spaces, data)
  group_names = []
  current_directory.each do |n|
    fs = File.lstat(n)
    group_names << Etc.getgrgid(fs.gid).name
  end
  spaces[:group_name_space] = group_names.map(&:size).max

  current_directory.each do |n|
    fs = File.lstat(n)
    group_name = Etc.getgrgid(fs.gid).name.rjust(spaces[:group_name_space] + 2)
    data << group_name
  end
end

def file_size(current_directory, spaces, data)
  file_sizes = []
  current_directory.each do |n|
    fs = File.lstat(n)
    file_sizes << fs.size.to_s
  end
  spaces[:file_size_space] = file_sizes.map(&:size).max

  current_directory.each do |n|
    fs = File.lstat(n)
    size = fs.size.to_s.rjust(spaces[:file_size_space] + 2)
    data << size
  end
end

def update_time(current_directory, data)
  half_year = (60 * 60 * 24 * 182.5)
  current_directory.each do |n|
    fs = File.lstat(n)
    time = Time.now - half_year < fs.mtime ? fs.mtime.strftime('%b %e %R') : fs.mtime.strftime('%b %e  %Y')
    data << " #{time}"
  end
end

def file_name(current_directory, data)
  current_directory.each { |n| data << " #{n}" }
end

def output_with_option_l
  current_directory = input
  spaces = {}
  data = []
  results = []

  blocks(current_directory)
  fyle_type(current_directory, data)
  permission(current_directory, data)
  nlink(current_directory, spaces, data)
  user_name(current_directory, spaces, data)
  group_name(current_directory, spaces, data)
  file_size(current_directory, spaces, data)
  update_time(current_directory, data)
  file_name(current_directory, data)

  data.each_slice(current_directory.size) { |n| results << n }

  count = 0
  results.transpose.flatten.each do |n|
    count += 1
    print n
    print "\n" if (count % 8).zero?
  end
end

main
