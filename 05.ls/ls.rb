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
  content_of_current_directories = []
  current_directory = input
  number_of_columns = 3

  current_directory << ' ' while current_directory.size % number_of_columns != 0
  max_number_of_rows = current_directory.size / number_of_columns
  current_directory.each_slice(max_number_of_rows) { |n| content_of_current_directories << n }

  results = content_of_current_directories.transpose.flatten
  space = current_directory.map(&:size).max
  count = 0
  results.each do |n|
    count += 1
    print n.ljust(space + 2)
    print "\n" if (count % 3).zero?
  end
end

def puts_total_blocks(current_directory)
  blocks = current_directory.map { |n| File.lstat(n).blocks }
  puts "total #{blocks.sum}"
end

def file_type(file_mode)
  file_type = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
  file_type[file_mode[0..1]]
end

def owner_permission(permission, special_permission, owner)
  special_permission == '4' ? permission[owner].sub(/x$|-$/, 'x' => 's', '-' => 'S') : permission[owner]
end

def group_permission(permission, special_permission, group)
  special_permission == '2' ? permission[group].sub(/x$|-$/, 'x' => 's', '-' => 'S') : permission[group]
end

def other_permission(permission, special_permission, other)
  special_permission == '1' ? permission[other].sub(/x$|-$/, 'x' => 't', '-' => 'T') : permission[other]
end

def permission(file_mode)
  permission = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
  permissions = []

  special_permission = file_mode[2]
  owner = file_mode[3]
  group = file_mode[4]
  other = file_mode[5]

  permissions << owner_permission(permission, special_permission, owner)
  permissions << group_permission(permission, special_permission, group)
  permissions << other_permission(permission, special_permission, other)

  permissions.join
end

def hard_link(space, file_stat)
  "#{file_stat.nlink.to_s.rjust(space[:nlink_space] + 2)} "
end

def user_name(space, file_stat)
  Etc.getpwuid(file_stat.uid).name.ljust(space[:user_name_space] + 2)
end

def group_name(space, file_stat)
  Etc.getgrgid(file_stat.gid).name.ljust(space[:group_name_space] + 1)
end

def file_size(space, file_stat)
  file_stat.size.to_s.rjust(space[:file_size_space] + 2)
end

def update_time(file_stat)
  half_year = (60 * 60 * 24 * 182.5)
  time = Time.now - half_year < file_stat.mtime ? file_stat.mtime.strftime('%b %e %R') : file_stat.mtime.strftime('%b %e  %Y')
  " #{time}"
end

def file_name(content_of_current_directories)
  " #{content_of_current_directories}"
end

def size_of_sapaces(current_directory)
  size_of_sapaces = {}
  size_of_sapaces[:nlink_space] = current_directory.map { |n| File.lstat(n).nlink.to_s.size }.max
  size_of_sapaces[:user_name_space] = current_directory.map { |n| Etc.getpwuid(File.lstat(n).uid).name.size }.max
  size_of_sapaces[:group_name_space] = current_directory.map { |n| Etc.getgrgid(File.lstat(n).gid).name.size }.max
  size_of_sapaces[:file_size_space] = current_directory.map { |n| File.lstat(n).size.to_s.size }.max

  size_of_sapaces
end

def output_with_option_l
  current_directory = input
  results = []
  space = size_of_sapaces(current_directory)

  puts_total_blocks(current_directory)

  current_directory.each do |content_of_current_directories|
    file_stat = File.lstat(content_of_current_directories)
    file_mode = file_stat.mode.to_s(8)
    file_mode.insert(0, '0') if file_mode.size == 5

    puts results = file_type(file_mode) +
                   permission(file_mode) +
                   hard_link(space, file_stat) +
                   user_name(space, file_stat) +
                   group_name(space, file_stat) +
                   file_size(space, file_stat) +
                   update_time(file_stat) +
                   file_name(content_of_current_directories)
  end
end

main
