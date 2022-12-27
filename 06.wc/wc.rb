# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  view_options = option
  files = parse_input(view_options)
  total_sizes = calc_total_sizes(files)
  output(files, total_sizes)
end

def option
  options = ARGV.getopts('lwc')
  { l: options['l'] || options.values.none?,
    w: options['w'] || options.values.none?,
    c: options['c'] || options.values.none? }
end

def parse_input(view_options)
  files = []
  while (argf = ARGF.gets(nil))
    files << { line_count: (argf.count("\n") if view_options[:l]),
               word_count: (argf.scan(/[^\s]+/).length if view_options[:w]),
               byte_count: (argf.bytesize if view_options[:c]),
               name: ARGF.filename == '-' ? '' : " #{ARGF.filename}" }
  end
  files
end

def calc_total_sizes(files)
  { line_count: (files.sum { |v| v[:line_count] } unless files[0][:line_count].nil?),
    word_count: (files.sum { |v| v[:word_count] } unless files[0][:word_count].nil?),
    byte_count: (files.sum { |v| v[:byte_count] } unless files[0][:byte_count].nil?),
    name: ' total' }
end

def output(files, total_sizes)
  files.each { |v| output_count(v) }
  return if files.size == 1

  output_count(total_sizes)
end

def output_count(files)
  result = [files[:line_count].to_s,
            files[:word_count].to_s,
            files[:byte_count].to_s]
  result.delete('')
  puts result.map { |v| v.rjust(8) }.join + files[:name]
end

main
