#!/usr/bin/ruby

depart_hour = ""
depart_minute = ""
type = "普"
destination = ""
contents = false

ARGF.each do |line|
  contents = true  if line =~ /<!-- 時刻表 -->/

  if contents then
    if line =~ /<FONT COLOR="#FFFFFF">(.+)<\/FONT>/ then
      depart_hour = sprintf("%02d", $~[1].to_i)
    end

    if line =~ /(区?快)<br>/ then
      type = $~[1]
    end

    if line =~ /(かもめ|みどり|ハウステンボス|有明|ゆふ| \
                 ゆふいんの森|ソニック|にちりん|きりしま|ひゅうが|きらめき)/ then
      ltdexp_train_name = line.chomp.gsub(/<.+>/, "")
      ltdexp_train_num  = ARGF.readline.chomp.gsub(/<.+>/, "") # 1行先読み

      if ltdexp_train_name == "ハウステンボス" and ltdexp_train_num == "" then next end

      type = "特" + ltdexp_train_name + ltdexp_train_num
      next
    end

    if line =~ /<b>(.+)<\/b>/ then
      depart_minute = $~[1]
    end

    if line =~ /^([^<]+?)(<br>&nbsp;)?$/ then
      destination = $~[1]
      puts "#{depart_hour}:#{depart_minute},#{type},#{destination}"
      type = "普"
    end
  end
end
