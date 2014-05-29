#usr/bin/ruby
require './twitter_config'
require 'MeCab'

# 2次マルコフ連鎖のための辞書作成

# ツイートを取得するユーザ達
users = [
	"2020miku_bot",
	"326miku_bot",
	"39miku39",
	"hatune_Miku_bot",
	"H__miku39",
	"kamon_miku_bot",
	"K_F_miku_bot",
	"miku2025_bot",
	"miku_0831bot",
	"miku_bot39",
	"Miku_bot_Aqua",
	"Miku_bot_ts",
	"miku_cho_bot",
	"Miku_Hatsun_bot",
	"Miku_kaiwa_bot",
	"MIKU_MIKU_831",
	"miku_miku_bot",
	"miku_negitoro",
	"Miku_TypeLat",
	"Miku_TypeTda",
	"miku__bot",
	"onda_miku_bot",
	"px_mikubot",
	"p_miku_bot",
	"santa_miku_bot",
	"sc_miku_bot",
	"snow_miku2013",
	"sune_miku_bot",
	"Tocha_miku",
	"van_miku_bot",
	"zarene_miku_bot"
];

mecab = MeCab::Tagger.new('-Ochasen')
map = Hash.new(0)

# 各ユーザについて
users.each do |user_name|
	# ユーザのツイート取得
	user_info = $client.user(user_name)
	tweets = $client.user_timeline(user_info, {:count=>100})

	# ツイート文の加工
	tw_text = Array.new
	tweets.each do |t|
		txt = t.text.dup
		# URLを削除
		txt = txt.gsub(/(https?:\/\/)?([\w*%#!()~\'-]+\.)+[\w*%#!()~\'-]+(\/[\w*%#!()~\'-.]+)*/, "")
		# メンションを削除
		txt = txt.gsub(/@[0-9a-zA-Z_]{1,15}/, "")
		# ハッシュタグを削除
		txt = txt.gsub(/#[0-9a-zA-Z]+/, "")
		tw_text.push(txt)
		puts txt
	end
	# 重複ツイートを削除
	tw_text.uniq!

	# 形態素解析
	tw_text.each do |t|
#		puts t
		node = mecab.parseToNode(t)
		pre2 = nil
		pre = nil
		while node != nil do
			if pre2 == nil then
				pre2 = node.surface
			elsif pre == nil then
				pre = node.surface
			else
#				print node.surface
#				print '/'
				map[[pre2, pre,node.surface]] = map[[pre2, pre,node.surface]] + 1
				pre2 = pre
				pre = node.surface
			end
			node = node.next
		end
#		puts ''
	end
end

# 辞書更新
# map.sort {|a, b| (a[0][0] != b[0][0]) ? (a[0][0] <=> b[0][0]) : ((a[0][1] != b[0][1]) ? (a[0][1] <=> b[0][1]) : (a[0][2] <=> b[0][2])) }
f = open("dic.txt", "w")
map.sort{|a, b| a[0] <=> b[0]}.to_a.each do |m|
	f.puts(m[0][0] + ',' + m[0][1] + ',' + m[0][2] + ',' + m[1].to_s)
end
f.close

puts "finished!"
