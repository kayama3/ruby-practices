# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

params = ARGV.getopts('clw')
OPTIONS_KEY = params.keys
OPTIONS_KEY_ORDER = %w[l w c].freeze

def main(params)
  file_names_contents = input
  file_names = file_names_contents.keys.map { |i| i == '-' ? ' ' : " #{i}" }
  file_contents = file_names_contents.values

  number_of_lines = count_lines(file_contents)
  number_of_words = count_words(file_contents)
  number_of_bytes = count_bytes(file_contents)

  sizes_names = sort_sizes_names(number_of_lines, number_of_words, number_of_bytes, file_names)
  sizes_names_with_options = sort_sizes_names_with_options(number_of_lines, number_of_words, number_of_bytes, file_names, params)

  sorted_total_sizes = calc_total_sizes(number_of_lines, number_of_words, number_of_bytes)
  total_sizes = sort_total_sizes(sorted_total_sizes)
  total_sizes_with_options = sort_total_sizes_with_options(params, sorted_total_sizes)

  output(sizes_names, sizes_names_with_options, total_sizes, total_sizes_with_options, params)
end

def input
  input = {}
  while (argf = ARGF.gets(nil))
    input[ARGF.filename] = argf
  end
  input
end

def count_lines(file_contents)
  file_contents.map { |i| i.count("\n").to_s.rjust(8) }
end

def count_words(file_contents)
  file_contents.map { |i| i.scan(/[^\s]+/).length.to_s.rjust(8) }
end

def count_bytes(file_contents)
  file_contents.map { |i| i.bytesize.to_s.rjust(8) }
end

def sort_sizes_names(number_of_lines, number_of_words, number_of_bytes, file_names)
  [number_of_lines, number_of_words, number_of_bytes, file_names].transpose.map(&:join)
end

def sort_sizes_names_with_options(number_of_lines, number_of_words, number_of_bytes, file_names, params)
  sizes_names = []
  sizes_names << number_of_lines if params['l']
  sizes_names << number_of_words if params['w']
  sizes_names << number_of_bytes if params['c']
  sizes_names << file_names
  sizes_names.transpose.map(&:join)
end

def calc_total_sizes(number_of_lines, number_of_words, number_of_bytes)
  calc_total_sizes = [number_of_lines.map(&:to_i).sum, number_of_words.map(&:to_i).sum, number_of_bytes.map(&:to_i).sum]
  sorted_options_key = OPTIONS_KEY.sort_by { |i| OPTIONS_KEY_ORDER.index(i[0]) }

  [sorted_options_key, calc_total_sizes].transpose.to_h
end

def sort_total_sizes(sorted_total_sizes)
  total_lines = sorted_total_sizes['l'].to_s.rjust(8)
  total_words = sorted_total_sizes['w'].to_s.rjust(8)
  total_bytes = sorted_total_sizes['c'].to_s.rjust(8)

  "#{total_lines}#{total_words}#{total_bytes} total"
end

def sort_total_sizes_with_options(params, sorted_total_sizes)
  total_lines = sorted_total_sizes['l'].to_s.rjust(8)
  total_words = sorted_total_sizes['w'].to_s.rjust(8)
  total_bytes = sorted_total_sizes['c'].to_s.rjust(8)

  "#{total_lines if params['l']}#{total_words if params['w']}#{total_bytes if params['c']} total"
end

def output(sizes_names, sizes_names_with_options, total_sizes, total_sizes_with_options, params)
  if params.values.any?
    puts sizes_names_with_options
    return unless ARGF.lineno > 1

    puts total_sizes_with_options
  else
    puts sizes_names
    return unless ARGF.lineno > 1

    puts total_sizes
  end
end

main(params)
