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
  content_of_current_directory = []
  current_directory = input
  number_of_columns = 3

  current_directory << ' ' while current_directory.size % number_of_columns != 0
  max_number_of_rows = current_directory.size / number_of_columns
  current_directory.each_slice(max_number_of_rows) { |n| content_of_current_directory << n }

  results = content_of_current_directory.transpose.flatten
  space = current_directory.map(&:size).max
  count = 0
  results.each do |n|
    count += 1
    print n.ljust(space + 2)
    print "\n" if (count % 3).zero?
  end
end

def blocks(current_directory)
  blocks = current_directory.map { |n| File.lstat(n).blocks }
  puts "total #{blocks.sum}"
end

def file_type(file_mode)
  file_type = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
  file_type[file_mode[0..1]]
end

def permission(file_mode)
  permission = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
  permissions = []
  count = 0

  file_mode[3, 3].each_char do |char|
    count += 1
    permissions << if file_mode[2] == '4' && count == 1
                     permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
                   elsif file_mode[2] == '2' && count == 2
                     permission[char].sub(/x$|-$/, 'x' => 's', '-' => 'S')
                   elsif file_mode[2] == '1' && count == 3
                     permission[char].sub(/x$|-$/, 'x' => 't', '-' => 'T')
                   else
                     permission[char]
                   end
  end
  permissions
end

def nlink(spaces, file_stat)
  file_stat.nlink.to_s.rjust(spaces[:nlink_space] + 2)
end

def user_name(spaces, file_stat)
  Etc.getpwuid(file_stat.uid).name.rjust(spaces[:user_name_space] + 1)
end

def group_name(spaces, file_stat)
  Etc.getgrgid(file_stat.gid).name.rjust(spaces[:group_name_space] + 2)
end

def file_size(spaces, file_stat)
  file_stat.size.to_s.rjust(spaces[:file_size_space] + 2)
end

def update_time(file_stat)
  half_year = (60 * 60 * 24 * 182.5)
  time = Time.now - half_year < file_stat.mtime ? file_stat.mtime.strftime('%b %e %R') : file_stat.mtime.strftime('%b %e  %Y')
  " #{time}"
end

def file_name(content_of_current_directory)
  " #{content_of_current_directory}"
end

def kinds_of_spaces(current_directory)
  kinds_of_spaces = {}
  kinds_of_spaces[:nlink_space] = current_directory.map { |n| File.lstat(n).nlink.to_s.size }.max
  kinds_of_spaces[:user_name_space] = current_directory.map { |n| Etc.getpwuid(File.lstat(n).uid).name.size }.max
  kinds_of_spaces[:group_name_space] = current_directory.map { |n| Etc.getgrgid(File.lstat(n).gid).name.size }.max
  kinds_of_spaces[:file_size_space] = current_directory.map { |n| File.lstat(n).size.to_s.size }.max

  kinds_of_spaces
end

def output_with_option_l
  current_directory = input
  results = []
  number_of_elemnts = 10

  spaces = kinds_of_spaces(current_directory)
  blocks(current_directory)

  current_directory.each do |content_of_current_directory|
    file_stat = File.lstat(content_of_current_directory)
    file_mode = file_stat.mode.to_s(8)
    file_mode.insert(0, '0') if file_mode.size == 5

    results << file_type(file_mode)
    results.concat permission(file_mode)
    results << nlink(spaces, file_stat)
    results << user_name(spaces, file_stat)
    results << group_name(spaces, file_stat)
    results << file_size(spaces, file_stat)
    results << update_time(file_stat)
    results << file_name(content_of_current_directory)
  end

  results.each_slice(number_of_elemnts) { |n| puts n.join }
end

main
