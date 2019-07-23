#!/usr/bin/ruby

depart_hour = ""
depart_minute = ""
type = "普"
destination = ""
contents_started = false

RE_HOUR = /<FONT COLOR="#FFFFFF">(.+)<\/FONT>/
RE_NICK = /(かもめ|みどり|ハウステンボス|有明|ゆふ|かいおう| \
            ゆふいんの森|ソニック|にちりん|きりしま|ひゅうが|きらめき| \
            つばめ|さくら|みずほ|こだま|ひかり|のぞみ|特急 \
            海幸山幸|はやとの風|指宿のたまて箱|なのはな|シーサイドライナー)/x




ARGF.each do |line|
  contents_started = true if /<!-- 時刻表 -->/ =~ line
  next if /<!--/ =~ line  # コンテンツ内のコメント行は読み飛ばす

  if contents_started
    if RE_HOUR =~ line
      depart_hour = sprintf("%02d", $~[1].to_i)
    end

    if line =~ /(区?快)<br>/
      type = $~[1]
    end

    if RE_NICK =~ line
      train_nickname = line.chomp.gsub(/<.+>/, "")
      ltdexp_train_num  = ARGF.readline.chomp.gsub(/<.+>/, "") # 1行先読み


      if train_nickname == "ハウステンボス" and ltdexp_train_num == ""
        next
      end
      if train_nickname == "特急"
        ltdexp_train_name = ""
      end

      if train_nickname == "ソニック"
        and_nichirin = ARGF.readline.chomp.gsub(/<.+>/, "") # さらに1行先読み
      else
        and_nichirin = ""
      end

      if train_nickname == "なのはな"
        type = "快なのはな"
      elsif train_nickname == "シーサイドライナー"
        type = type + "シーサイドライナー"
      else
        type = "特" + train_nickname + ltdexp_train_num + and_nichirin
      end

      next
    end

    if /<b>(.+)<\/b>/ =~ line
      depart_minute = $~[1]
    end

    if /^([^<]+?)(<br>&nbsp;)?$/ =~ line
      destination = $~[1]
      puts "#{depart_hour}:#{depart_minute},#{type},#{destination}"
      type = "普"
    end
  end
end
