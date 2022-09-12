# /usr/bin/env ruby
# frozen_string_literal: true

current_directory = Dir.glob('*')
original_dummy_id = current_directory.find { |x| x == 'dummy' }.object_id
current_directory << 'dummy' while current_directory.size % 3 != 0

def sort(current_directory)
  items = []
  column = current_directory.size / 3
  current_directory.each_slice(column) { |n| items << n }
  items.transpose.flatten
end

item = sort(current_directory)
space = current_directory.map(&:size).max

def output(item, space, original_dummy_id)
  count = 0
  item.each do |n|
    count += 1
    print n.ljust(space + 2) if n != 'dummy' || n.object_id == original_dummy_id
    print "\n" if (count % 3).zero?
  end
end
output(item, space, original_dummy_id)