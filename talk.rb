#usr/bin/ruby
require './twitter_config'

# 辞書から文章生成、ツイート
# 2次マルコフ連鎖を想定

lines = 0			# 行数
map = Hash.new(0)
text = ""			# 生成文字列
w1 = w2 = w3 = ""		# 直前の単語

# 文章生成
open("dic.txt") { |file|
	inputs = file.readlines
	inputs.each do |l|
		lines += 1
		words = l.split(',')
		map[words[0..2]] = words[3].to_i
	end

	# 最初の1語を決定
	index = rand(lines)
	firstWords = inputs[index].split(',')
	w1 = firstWords[0]
	w2 = firstWords[1]
	w3 = firstWords[2]
	text += w1 + w2 + w3
}

lim = 140 - w1.length - w2.length - w3.length
while lim<0 do
	# 2分探索でmapからw2,w3をw1,w2として持つ要素群の先頭を探す
	l = 0
	r = lines-1
	found = false
	while l < r do
		center = (l+r) / 2
		if map[center][0..1] < [w2,w3] then
			l = center+1
		elsif map[center][0..1] > [w2,w3] then
			r = center-1
		else
			l = r = center
			while 0<=l && map[center][0..1] == map[l][0..1] do
				l -= 1
			end
			l += 1
			while r<lines && map[center][0..1] == map[r][0..1] do
				r += 1
			end
			found = true
			break
		end
	end

	# 見つからなかったら終了
	if !found then
		break
	end

	# l..r-1のカウント値の総和を計算
	sum = 0
	for i in l..r-1 do
		sum += map[i][3]
	end

	# 繋ぐ単語を決定
	rnd = rand(sum)
	index = l
	while index < r && 0 < rnd do
		rnd -= map[index][3]
		index += 1
	end

	# 文章生成とか
	text += map[index][2]
	lim -= map[index][2].length
	w1 = map[index][0]
	w2 = map[index][1]
	w3 = map[index][2]

end

# twitterにツイート
puts text
$client.update(text)
