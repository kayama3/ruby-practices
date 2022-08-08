#!/usr/bin/env ruby
require 'date'
require 'optparse'

# -yと-mの設定
option = {}
OptionParser.new do |opt|
  opt.on('-y value') {|v| option[:y] = v}
  opt.on('-m value') {|v| option[:m] = v}
  opt.parse!(ARGV)
end

now = Date.today

# yearに変数を代入
year = 
if option[:y]
  option[:y]
else
  now.year
end

# monthに変数を代入
month =
if option[:m]
  option[:m]
else
  now.month
end

# 月の初日と最終日の設定
first_day = Date.new(year.to_i, month.to_i, 1)
last_day = Date.new(year.to_i, month.to_i, -1)

# 月、年、曜日を表示
puts "       #{month} #{year}"
puts "Su Mo Tu We Th Fr Sa"

# 初日の前に空白を表示
space = first_day.wday * 3 
print " " * space 

# 初日から最終日まで表示
(first_day..last_day).each do |d|
  print "#{d.day} ".rjust(3)
  print "\n" if d.saturday?
end
