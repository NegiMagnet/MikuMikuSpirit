#usr/bin/ruby
require './twitter_config'
require 'MeCab'

# 2次マルコフ連鎖のための辞書作成

# ツイートを取得するユーザ達
users = [
	"Miku_TypeTda",
	"Miku_TypeLat",
	"Miku_Hatsun_bot",
	"px_mikubot",
	"Miku_bot_ts",
	"miku_cho_bot",
	"Miku_bot_Aqua",
	"santa_miku_bot",
	"hatune_Miku_bot",
	"miku_miku_bot"
];

mecab = MeCab::Tagger.new('-Ochasen')
map = Hash.new(0)

# 各ユーザについて
users.each do |user_name|
	# ユーザのツイート取得
	user_info = $client.user(user_name)
	tweets = $client.user_timeline(user_info, {:count=>100})

	# ツイート文のみ取得, ついでに頭の@xxxx を削除
	tw_text = Array.new
	tweets.each do |t|
		txt = t.text.dup
		start = 0
		if txt[0] == '@' then
			for i in 0..t.text.length do
				if txt[i] == ' ' then
					start = i+1
					break
				end
			end
		end
		tw_text.push(txt[start..txt.length-1])
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
