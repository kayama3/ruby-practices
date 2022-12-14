# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

params = ARGV.getopts('clw')
OPTIONS_KEY = params.keys
OPTIONS_KEY_ORDER = %w[l w c].freeze

def main(params)
  input = input()
  file_name = input.keys.map { |x| x == '-' ? ' ' : " #{x}" }
  file_contents = input.values

  lines = number_of_lines(file_contents)
  words = number_of_words(file_contents)
  bytes = number_of_bytes(file_contents)

  elements = elements(lines, words, bytes, file_name)
  elements_with_options = elements_with_options(lines, words, bytes, file_name, params)

  calc_total_elements = calc_total_elements(lines, words, bytes)
  total_elements = total_elements(calc_total_elements)
  total_elements_with_options = total_elements_with_options(params, calc_total_elements)

  output(elements, elements_with_options, total_elements, total_elements_with_options, params)
end

def input
  input = {}
  while (argf = ARGF.gets(nil))
    input[ARGF.filename] = argf
  end
  input
end

def number_of_lines(file_contents)
  file_contents.map { |x| x.count("\n").to_s.rjust(8) }
end

def number_of_words(file_contents)
  file_contents.map { |x| x.scan(/[^\s]+/).length.to_s.rjust(8) }
end

def number_of_bytes(file_contents)
  file_contents.map { |x| x.bytesize.to_s.rjust(8) }
end

def elements(lines, words, bytes, file_name)
  [lines, words, bytes, file_name].transpose.map(&:join)
end

def elements_with_options(lines, words, bytes, file_name, params)
  elements_with_options = []
  elements_with_options << lines if params['l']
  elements_with_options << words if params['w']
  elements_with_options << bytes if params['c']
  elements_with_options << file_name
  elements_with_options.transpose.map(&:join)
end

def calc_total_elements(lines, words, bytes)
  calc_total_elements = [lines.map(&:to_i).sum, words.map(&:to_i).sum, bytes.map(&:to_i).sum]
  sorted_options_key = OPTIONS_KEY.sort_by { |x| OPTIONS_KEY_ORDER.index(x[0]) }

  [sorted_options_key, calc_total_elements].transpose.to_h
end

def total_elements(calc_total_elements)
  total_lines = calc_total_elements['l'].to_s.rjust(8)
  total_words = calc_total_elements['w'].to_s.rjust(8)
  total_bytes = calc_total_elements['c'].to_s.rjust(8)

  "#{total_lines}#{total_words}#{total_bytes} total"
end

def total_elements_with_options(params, calc_total_elements)
  total_lines = calc_total_elements['l'].to_s.rjust(8)
  total_words = calc_total_elements['w'].to_s.rjust(8)
  total_bytes = calc_total_elements['c'].to_s.rjust(8)

  "#{total_lines if params['l']}#{total_words if params['w']}#{total_bytes if params['c']} total"
end

def output(elements, elements_with_options, total_elements, total_elements_with_options, params)
  if params.values.any?
    puts elements_with_options
    return unless ARGF.lineno > 1

    puts total_elements_with_options
  else
    puts elements
    return unless ARGF.lineno > 1

    puts total_elements
  end
end

main(params)
