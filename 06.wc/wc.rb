# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  view_options = parse_view_options
  files = parse_input
  total_sizes = calc_total_sizes(files)
  output(files, total_sizes, view_options)
end

def parse_view_options
  options = ARGV.getopts('lwc')
  { l: options['l'] || options.values.none?,
    w: options['w'] || options.values.none?,
    c: options['c'] || options.values.none? }
end

def parse_input
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
  { line_count: files.sum { |v| v[:line_count].to_i },
    word_count: files.sum { |v| v[:word_count].to_i },
    byte_count: files.sum { |v| v[:byte_count].to_i },
    name: ' total' }
end

def output(files, total_sizes, view_options)
  files.each { |v| output_count(v, view_options) }
  return if files.size == 1

  output_count(total_sizes, view_options)
end

def output_count(files, view_options)
  puts [(files[:line_count].to_s.rjust(8) if view_options[:l]),
        (files[:word_count].to_s.rjust(8) if view_options[:w]),
        (files[:byte_count].to_s.rjust(8) if view_options[:c]),
        files[:name]].join
end

main
