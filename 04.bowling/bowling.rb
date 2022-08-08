#!/usr/bin/env ruby
score = ARGV[0] 
scores = score.split(',') 

# 足し算するために数字に変換
shots = []
scores.each do |s|
  if s == 'X' && shots.count < 18 
    shots << 10
    shots << 0
  elsif s == 'X' && shots.count >= 18 
    shots << 10
  else
    shots << s.to_i
  end
end

# フレームごとに分割
frames = []
shots.each_slice(2) do |s|
  frames << s
  if frames[10] 
    frames << frames[9] + frames[10]
    frames.slice!(-3, 2)
  end
end

# 1-8フレームまでの処理
point = 0
frames.each_cons(3) do |three_frames| 
  if three_frames[0][0] == 10 # strike
    three_frames.flatten!.delete(0) 
    point += three_frames.first(3).sum
  elsif three_frames[0].sum == 10 # spare
    three_frames.flatten!
    point += three_frames.first(3).sum
  else
    point += three_frames[0].sum
  end
end

# 9,10フレームの処理
if frames[8][0] == 10 # strike
  point += frames[8][0] + frames[9][0] + frames[9][1]
elsif frames[8].sum == 10 # spare
  point += frames[8].sum + frames[9][0]
else
  point += frames[8].sum
end
p point += frames[9].sum
