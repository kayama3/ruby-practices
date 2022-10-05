# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
params = ARGV.getopts('r')

current_directory = Dir.glob('*')
params["r"] ? current_directory.reverse! : current_directory
current_directory << ' ' while current_directory.size % 3 != 0
MAX_NUMBER_OF_COLUMNS = current_directory.size / 3

def sort(current_directory)
  items = []
  current_directory.each_slice(MAX_NUMBER_OF_COLUMNS) { |n| items << n }
  items.transpose.flatten
end

item = sort(current_directory)
space = current_directory.map(&:size).max

def output(item, space)
  count = 0
  item.each do |n|
    count += 1
    print n.ljust(space + 2)
    print "\n" if (count % 3).zero?
  end
end
output(item, space)
