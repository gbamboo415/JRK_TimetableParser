#!/usr/bin/ruby

depart_hour = ""
depart_minute = ""
type = "普"
destination = ""

RE_HOUR  = /<FONT COLOR="#FFFFFF">(.+)<\/FONT>/
RE_RAPID = /(区?快)<br>/
RE_NICK  = /(かもめ|みどり|ハウステンボス|有明|ゆふ|かいおう| \
             ゆふいんの森|ソニック|にちりん|きりしま|ひゅうが|きらめき| \
             つばめ|さくら|みずほ|こだま|ひかり|のぞみ|特急 \
             海幸山幸|はやとの風|指宿のたまて箱|なのはな|シーサイドライナー)/x
RE_MINUTE = /<b>(.+)<\/b>/
RE_DESTINATION = /^([^<]+?)(<br>&nbsp;)?$/

fname = ARGV.shift
if fname == nil
  f = STDIN
else
  f = open(fname)
end

f.gets("\n<!-- 時刻表 -->\n") # 時刻表本体の開始部分まで読み飛ばす

while line = f.gets
  next if /<!--/ =~ line  # コンテンツ内のコメント行は読み飛ばす

  if RE_HOUR =~ line
    depart_hour = sprintf("%02d", $~[1].to_i)
    next
  end

  if RE_RAPID =~ line     # 快速・区間快速表記の場合
    type = $~[1]
    next
  end

  if RE_NICK =~ line
    train_nickname = line.chomp.gsub(/<.+>/, "")
    num_of_train   = f.gets.chomp.gsub(/<.+>/, "") # 1行先読み

    if train_nickname == "ハウステンボス" and ltdexp_train_num == ""
      next
    end

    if train_nickname == "特急" # 博多南線の無名特急
      train_nickname = ""
      next
    end

    if train_nickname == "ソニック"
      and_nichirin = f.gets.chomp.gsub(/<.+>/, "") # (&にちりん) が付いていないか、さらに1行先読み
    else
      and_nichirin = ""
    end

    if train_nickname == "なのはな" or train_nickname == "シーサイドライナー"
      type = type + train_nickname + num_of_train
    else
      type = "特" + train_nickname + num_of_train + and_nichirin
    end

    next
  end

  if RE_MINUTE =~ line
    depart_minute = $~[1]
    next
  end

  if RE_DESTINATION =~ line
    destination = $~[1]
    puts "#{depart_hour}:#{depart_minute},#{type},#{destination}"
    type = "普"
  end
end
