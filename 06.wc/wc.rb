# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

option = ARGV.getopts('clw')
OPTIONS_KEY = option.keys
OPTIONS_KEY_ORDER = %w[l w c].freeze

def main(option)
  files = input
  total_sizes = calc_total_sizes(files)
  output(files, total_sizes, option)
end

def input
  files = []
  while (argf = ARGF.gets(nil))
    files << { line_count: argf.count("\n"),
               word_count: argf.scan(/[^\s]+/).length,
               byte_count: argf.bytesize,
               name: ARGF.filename == '-' ? ' ' : " #{ARGF.filename}" }
  end
  files
end

def calc_total_sizes(files)
  { line_count: files.sum { |v| v[:line_count].to_i },
    word_count: files.sum { |v| v[:word_count].to_i },
    byte_count: files.sum { |v| v[:byte_count].to_i },
    name: ' total' }
end

def output(files, total_sizes, option)
  if option.values.any?
    files.each do |v|
      output_count(v, option)
    end
    return if files.size == 1

    output_count(total_sizes, option)
  else
    files.each do |v|
      puts v[:line_count].to_s.rjust(8) +
           v[:word_count].to_s.rjust(8) +
           v[:byte_count].to_s.rjust(8) +
           v[:name]
    end
    return if files.size == 1

    puts total_sizes[:line_count].to_s.rjust(8) +
         total_sizes[:word_count].to_s.rjust(8) +
         total_sizes[:byte_count].to_s.rjust(8) +
         total_sizes[:name]
  end
end

def output_count(files, option)
  print files[:line_count].to_s.rjust(8) if option['l']
  print files[:word_count].to_s.rjust(8) if option['w']
  print files[:byte_count].to_s.rjust(8) if option['c']
  puts files[:name]
end

main(option)
