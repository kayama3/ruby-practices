# /usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'optparse'
params = ARGV.getopts('l')

current_directory = Dir.glob('*')
unless params['l']
  current_directory << ' ' while current_directory.size % 3 != 0
  MAX_NUMBER_OF_COLUMNS = current_directory.size / 3

  def sort(current_directory)
    items = []
    current_directory.each_slice(MAX_NUMBER_OF_COLUMNS) { |n| items << n }
    items.transpose.flatten
  end

  item = sort(current_directory)
  space = current_directory.map(&:size).max
end

def output(item, space)
  count = 0
  item.each do |n|
    count += 1
    print n.ljust(space + 2)
    print "\n" if (count % 3).zero?
  end
end

nlinks = []
user_names = []
group_names = []
file_sizes = []
spaces = {}
current_directory.each do |n|
  fs = File.lstat(n)
  nlinks << fs.nlink.to_s
  user_names << Etc.getpwuid(fs.uid).name
  group_names << Etc.getgrgid(fs.gid).name
  file_sizes << fs.size.to_s
end
spaces[:nlink_space] = nlinks.map(&:size).max
spaces[:user_name_space] = user_names.map(&:size).max
spaces[:group_name_space] = group_names.map(&:size).max
spaces[:file_size_space] = file_sizes.map(&:size).max

fyle_type = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
permission = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
half_year = (60 * 60 * 24 * 182.5)

def output_blocks(current_directory)
  total_blocks = 0
  current_directory.each { |n| total_blocks += File.lstat(n).blocks }
  puts "total #{total_blocks}"
end

def output_with_option_l(current_directory, spaces, fyle_type, permission, half_year)
  current_directory.each do |n|
    fs = File.lstat(n)
    split_fs = fs.mode.to_s(8).split('')
    split_fs.insert(0, '0') if split_fs.size == 5

    nlink = fs.nlink.to_s.rjust(spaces[:nlink_space] + 2)
    user_name = Etc.getpwuid(fs.uid).name.rjust(spaces[:user_name_space] + 1)
    group_name = Etc.getgrgid(fs.gid).name.rjust(spaces[:group_name_space] + 2)
    size = fs.size.to_s.rjust(spaces[:file_size_space] + 2)
    time = Time.now - half_year < fs.mtime ? fs.mtime.strftime('%b %e %R') : fs.mtime.strftime('%b %e  %Y')

    fyle_type.each { |key, value| print value if split_fs[0] + split_fs[1] == key }
    permission.each do |key, value|
      if split_fs[3] == key # owner
        print split_fs[2] == '4' ? value.sub(/x$|-$/, 'x' => 's', '-' => 'S') : value # SUID
      end
    end
    permission.each do |key, value|
      if split_fs[4] == key # group
        print split_fs[2] == '2' ? value.sub(/x$|-$/, 'x' => 's', '-' => 'S') : value # SGID
      end
    end
    permission.each do |key, value|
      if split_fs[5] == key # other
        print split_fs[2] == '1' ? value.sub(/x$|-$/, 'x' => 't', '-' => 'T') : value # スティッキービット
      end
    end

    print "#{nlink}#{user_name}#{group_name}#{size} #{time} #{n}\n"
  end
end

if params['l']
  output_blocks(current_directory)
  output_with_option_l(current_directory, spaces, fyle_type, permission, half_year)
else
  output(item, space)
end
