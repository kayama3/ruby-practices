# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  option = ARGV.getopts('lwc')
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
               name: ARGF.filename == '-' ? '' : " #{ARGF.filename}" }
  end
  files
end

def calc_total_sizes(files)
  { line_count: files.sum { |v| v[:line_count] },
    word_count: files.sum { |v| v[:word_count] },
    byte_count: files.sum { |v| v[:byte_count] },
    name: ' total' }
end

def output(files, total_sizes, option)
  files.each { |v| output_count(v, option) }
  return if files.size == 1

  output_count(total_sizes, option)
end

def options(files, option)
  { l: option['l'] ? files[:line_count].to_s.rjust(8) : '',
    w: option['w'] ? files[:word_count].to_s.rjust(8) : '',
    c: option['c'] ? files[:byte_count].to_s.rjust(8) : '',
    lwc: option.values.any? ? '' : files[:line_count].to_s.rjust(8) + files[:word_count].to_s.rjust(8) + files[:byte_count].to_s.rjust(8) }
end

def output_count(files, option)
  view_options = options(files, option)
  puts view_options[:l] +
       view_options[:w] +
       view_options[:c] +
       view_options[:lwc] +
       files[:name]
end

main
