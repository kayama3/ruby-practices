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

# yearとmonthの条件分岐
if option[:y] && option[:m]
  year = option[:y]
  month = option[:m]
elsif option[:m]
  now = Date.today
  year = now.year
  month = option[:m]
else  
  now = Date.today
  year = now.year
  month = now.month
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

# 初日から９日まで表示
(first_day..first_day + 8).each{|d|
  print " #{d.day} " 
  print "\n" if d.saturday?
}

# １０日から最終日まで表示
(first_day + 9.. last_day).each{|d|
  print "#{d.day} "
  print "\n" if d.saturday?
}
