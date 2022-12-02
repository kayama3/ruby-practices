# /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  params = ARGV.getopts('clw')
  output(params)
end

def number_of_lines(argf)
  argf.count("\n").to_s.rjust(8)
end

def number_of_words(argf)
  argf.scan(/[^\s]+/).length.to_s.rjust(8)
end

def number_of_bytes(argf)
  argf.bytesize.to_s.rjust(8)
end

def file_name
  " #{ARGF.filename}".delete("\-")
end

def print_lines_words_bytes(argf)
  print number_of_lines(argf)
  print number_of_words(argf)
  print number_of_bytes(argf)
  print "#{file_name}\n"
end

def print_lines_words_bytes_with_options(argf, params)
  print number_of_lines(argf) if params['l']
  print number_of_words(argf) if params['w']
  print number_of_bytes(argf) if params['c']
  print "#{file_name}\n"
end

def get_total_lines_words_bytes(argf, total_lines_words_bytes)
  total_lines_words_bytes.push(number_of_lines(argf).to_i,
                               number_of_words(argf).to_i,
                               number_of_bytes(argf).to_i)
end

def total_lines_words_bytes(params, total_lines_words_bytes)
  calc_total_lines_words_bytes = total_lines_words_bytes.each_slice(3).to_a.transpose.map { |array| array.inject(:+) }
  ary = [params.keys, calc_total_lines_words_bytes].transpose
  Hash[*ary.flatten]
end

def print_total_lines_words_bytes(params, total_lines_words_bytes)
  total_lines = total_lines_words_bytes(params, total_lines_words_bytes)['l'].to_s.rjust(8)
  total_words = total_lines_words_bytes(params, total_lines_words_bytes)['w'].to_s.rjust(8)
  total_bytes = total_lines_words_bytes(params, total_lines_words_bytes)['c'].to_s.rjust(8)

  print total_lines if params['l']
  print total_words if params['w']
  print total_bytes if params['c']
  print ' total'
end

def output(params)
  total_lines_words_bytes = []

  while (argf = ARGF.gets(nil))
    get_total_lines_words_bytes(argf, total_lines_words_bytes)

    if params.values.any? == false
      print_lines_words_bytes(argf)
    else
      print_lines_words_bytes_with_options(argf, params)
    end
  end

  print_total_lines_words_bytes(params, total_lines_words_bytes) if ARGF.lineno > 1
end

main
