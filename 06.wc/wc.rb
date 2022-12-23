# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  option = ARGV.getopts('lwc')
  files = input(option)
  total_sizes = calc_total_sizes(files, option)
  output(files, total_sizes, option)
end

def input(option)
  files = []
  while (argf = ARGF.gets(nil))
    files << { line_count: argf.count("\n"),
               word_count: argf.scan(/[^\s]+/).length,
               byte_count: argf.bytesize,
               option_l: option['l'] ? argf.count("\n") : nil,
               option_w: option['w'] ? argf.scan(/[^\s]+/).length : nil,
               option_c: option['c'] ? argf.bytesize : nil,
               name: ARGF.filename == '-' ? ' ' : " #{ARGF.filename}" }
  end
  files
end

def calc_total_sizes(files, option)
  { line_count: files.sum { |v| v[:line_count] },
    word_count: files.sum { |v| v[:word_count] },
    byte_count: files.sum { |v| v[:byte_count] },
    option_l: option['l'] ? files.sum { |v| v[:option_l] } : nil,
    option_w: option['w'] ? files.sum { |v| v[:option_w] } : nil,
    option_c: option['c'] ? files.sum { |v| v[:option_c] } : nil,
    name: ' total' }
end

def output(files, total_sizes, option)
  total_sizes[:name] = ' total'
  if option.values.any?
    files.each do |v|
      output_count_options(v)
    end
    return if files.size == 1

    output_count_options(total_sizes)
  else
    files.each do |v|
      output_count(v)
    end
    return if files.size == 1

    output_count(total_sizes)
  end
end

def output_count_options(files)
  result = [files[:option_l].to_s,
            files[:option_w].to_s,
            files[:option_c].to_s]
  result.delete('')

  puts result.map { |v| v.rjust(8) }.join + files[:name]
end

def output_count(files)
  puts files[:line_count].to_s.rjust(8) +
       files[:word_count].to_s.rjust(8) +
       files[:byte_count].to_s.rjust(8) +
       files[:name]
end

main
