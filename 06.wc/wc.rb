# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

option = ARGV.getopts('clw')
OPTIONS_KEY = option.keys
OPTIONS_KEY_ORDER = %w[l w c].freeze

def main(option)
  sizes_names = input
  total_sizes = sort_total_sizes(sizes_names)
  output(sizes_names, total_sizes, option)
end

def input
  sizes_names = []
  while (argf = ARGF.gets(nil))
    sizes_names << { lines: argf.count("\n").to_s.rjust(8),
                     words: argf.scan(/[^\s]+/).length.to_s.rjust(8),
                     bytes: argf.bytesize.to_s.rjust(8),
                     name: ARGF.filename == '-' ? ' ' : " #{ARGF.filename}" }
  end
  sizes_names
end

def sort_total_sizes(sizes_names)
  { lines: sizes_names.map { |v| v[:lines].to_i }.sum.to_s.rjust(8),
    words: sizes_names.map { |v| v[:words].to_i }.sum.to_s.rjust(8),
    bytes: sizes_names.map { |v| v[:bytes].to_i }.sum.to_s.rjust(8) }
end

def output(sizes_names, total_sizes, option)
  if option.values.any?
    sizes_names.each do |file|
      print file[:lines] if option['l']
      print file[:words] if option['w']
      print file[:bytes] if option['c']
      puts file[:name]
    end
    return if sizes_names.size == 1

    print total_sizes[:lines] if option['l']
    print total_sizes[:words] if option['w']
    print total_sizes[:bytes] if option['c']
    puts ' total'
  else
    puts(sizes_names.map { |v| v.values.join })
    return if sizes_names.size == 1

    puts "#{total_sizes.values.join} total"
  end
end

main(option)
