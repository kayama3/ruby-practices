# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  view_options = option
  parse_input = input(view_options)
  total_sizes = calc_total_sizes(parse_input)
  output(parse_input, total_sizes)
end

def option
  options = ARGV.getopts('lwc')
  { l: options['l'] || options.values.none?,
    w: options['w'] || options.values.none?,
    c: options['c'] || options.values.none? }
end

def input(view_options)
  files = []
  while (argf = ARGF.gets(nil))
    files << { line_count: (argf.count("\n") if view_options[:l]),
               word_count: (argf.scan(/[^\s]+/).length if view_options[:w]),
               byte_count: (argf.bytesize if view_options[:c]),
               name: ARGF.filename == '-' ? '' : " #{ARGF.filename}" }
  end
  files
end

def calc_total_sizes(parse_input)
  { line_count: (parse_input.sum { |v| v[:line_count] } unless parse_input[0][:line_count].nil?),
    word_count: (parse_input.sum { |v| v[:word_count] } unless parse_input[0][:word_count].nil?),
    byte_count: (parse_input.sum { |v| v[:byte_count] } unless parse_input[0][:byte_count].nil?),
    name: ' total' }
end

def output(parse_input, total_sizes)
  parse_input.each { |v| output_count(v) }
  return if parse_input.size == 1

  output_count(total_sizes)
end

def output_count(parse_input)
  result = [parse_input[:line_count].to_s,
            parse_input[:word_count].to_s,
            parse_input[:byte_count].to_s]
  result.delete('')
  puts result.map { |v| v.rjust(8) }.join + parse_input[:name]
end

main
