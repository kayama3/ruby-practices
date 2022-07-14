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

# 年と月が指定された場合の動作
if option[:y] && option[:m]
  year = option[:y]
  month = option[:m]
  first = Date.new(year.to_i, month.to_i, 1)
  last = Date.new(year.to_i, month.to_i, -1)

  # 月、年、曜日を表示
  print "       ",first.strftime('%b'), " ", first.strftime('%Y')
  puts "\nSu Mo Tu We Th Fr Sa"

  # 初日を表示
  if first.sunday? == true && first == Date.today
    print "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.sunday? == true
    print first.strftime('%e'), " "
  elsif first.monday? == true && first == Date.today
    print "   ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.monday? == true
    print "   ", first.strftime('%e'), " "
  elsif first.tuesday? == true && first == Date.today
    print "      ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.tuesday? == true
    print "      ", first.strftime('%e'), " "
  elsif first.wednesday? == true && first == Date.today
    print "         ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.wednesday? == true
    print "         ", first.strftime('%e'), " "
  elsif first.thursday? == true && first == Date.today
    print "            ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.thursday? == true
    print "            ", first.strftime('%e'), " "
  elsif first.friday? == true && first == Date.today
    print "               ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.friday? == true
    print "               ", first.strftime('%e'), " "
  elsif first.saturday? == true && first == Date.today
    print "                  ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.saturday? == true
    print "                  ", first.strftime('%e'), "\n"
  end

  # 初日以降を表示
  while first < last
    first += 1
    if first == Date.today && first.saturday? == true
      print  "\e[7m#{first.strftime('%e')}\e[0m", "\n"
    elsif first == Date.today
      print  "\e[7m#{first.strftime('%e')}\e[0m", " "
    elsif first.saturday? == true 
      print first.strftime('%e'), "\n"
    elsif
      print first.strftime('%e'), " "
    end
  end

# 月のみ指定した場合の動作
elsif option[:m]
  now = Date.today
  year = now.year
  month = option[:m]
  first = Date.new(year.to_i, month.to_i, 1)
  last = Date.new(year.to_i, month.to_i, -1)

  # 月、年、曜日を表示
  print "       ",first.strftime('%b'), " ", first.strftime('%Y')
  puts "\nSu Mo Tu We Th Fr Sa"

  # 初日を表示
  if first.sunday? == true && first == Date.today
    print "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.sunday? == true
    print first.strftime('%e'), " "
  elsif first.monday? == true && first == Date.today
    print "   ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.monday? == true
    print "   ", first.strftime('%e'), " "
  elsif first.tuesday? == true && first == Date.today
    print "      ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.tuesday? == true
    print "      ", first.strftime('%e'), " "
  elsif first.wednesday? == true && first == Date.today
    print "         ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.wednesday? == true
    print "         ", first.strftime('%e'), " "
  elsif first.thursday? == true && first == Date.today
    print "            ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.thursday? == true
    print "            ", first.strftime('%e'), " "
  elsif first.friday? == true && first == Date.today
    print "               ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.friday? == true
    print "               ", first.strftime('%e'), " "
  elsif first.saturday? == true && first == Date.today
    print "                  ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.saturday? == true
    print "                  ", first.strftime('%e'), "\n"
  end

  # 初日以降を表示
  while first < last
    first += 1
    if first == Date.today && first.saturday? == true
      print  "\e[7m#{first.strftime('%e')}\e[0m", "\n"
    elsif first == Date.today
      print  "\e[7m#{first.strftime('%e')}\e[0m", " "
    elsif first.saturday? == true 
      print first.strftime('%e'), "\n"
    elsif
      print first.strftime('%e'), " "
    end
  end

# 年と月を指定しない場合の動作
elsif
  now = Date.today
  year = now.year
  month = now.month
  first = Date.new(year, month, 1)
  last = Date.new(year, month, -1)

  # 月、年、曜日を表示
  print "       ",now.strftime('%b'), " ", now.strftime('%Y')
  puts "\nSu Mo Tu We Th Fr Sa"

  # 初日を表示
  if first.sunday? == true && first == Date.today
    print "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.sunday? == true
    print first.strftime('%e'), " "
  elsif first.monday? == true && first == Date.today
    print "   ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.monday? == true
    print "   ", first.strftime('%e'), " "
  elsif first.tuesday? == true && first == Date.today
    print "      ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.tuesday? == true
    print "      ", first.strftime('%e'), " "
  elsif first.wednesday? == true && first == Date.today
    print "         ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.wednesday? == true
    print "         ", first.strftime('%e'), " "
  elsif first.thursday? == true && first == Date.today
    print "            ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.thursday? == true
    print "            ", first.strftime('%e'), " "
  elsif first.friday? == true && first == Date.today
    print "               ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.friday? == true
    print "               ", first.strftime('%e'), " "
  elsif first.saturday? == true && first == Date.today
    print "                  ", "\e[7m#{first.strftime('%e')}\e[0m", " "
  elsif first.saturday? == true
    print "                  ", first.strftime('%e'), "\n"
  end

  # 初日以降を表示
  while first < last
    first += 1
    if first == Date.today && first.saturday? == true
      print  "\e[7m#{first.strftime('%e')}\e[0m", "\n"
    elsif first == Date.today
      print  "\e[7m#{first.strftime('%e')}\e[0m", " "
    elsif first.saturday? == true 
      print first.strftime('%e'), "\n"
    elsif
      print first.strftime('%e'), " "
    end
  end
end
