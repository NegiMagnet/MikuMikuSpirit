#usr/bin/ruby
require './twitter_config'

# 辞書から文章生成、ツイート
# 1次マルコフ連鎖を想定

lines = 0			# 行数
map = Hash.new(0)
text = ""			# 生成文字列
w1 = w2 = ""		# 直前の単語

# 文章生成
open("dic_n.txt") { |file|
	inputs = file.readlines
	inputs.each do |l|
		lines += 1
		words = l.split(',')
		map[words[0..1]] = words[2].to_i
	end

	# 最初の1語を決定
	index = rand(lines)
	firstWords = inputs[index].split(',')
	w1 = firstWords[0]
	w2 = firstWords[1]
	text += w1 + w2
}

mapArray = map.to_a

lim = 140 - w1.length - w2.length
while lim>0 do
	# 2分探索でmapからw2をw1として持つ要素群の先頭を探す
	l = 0
	r = lines-1
	found = false
	while l < r do
		center = (l+r) / 2
		if mapArray[center][0][0] < w2 then
			l = center+1
		elsif mapArray[center][0][0] > w2 then
			r = center-1
		else
			l = r = center
			while 0<=l && mapArray[center][0][0] == mapArray[l][0][0] do
				l -= 1
			end
			l += 1
			while r<lines && mapArray[center][0][0] == mapArray[r][0][0] do
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
		sum += mapArray[i][1]
	end

	# 繋ぐ単語を決定
	rnd = rand(sum)
	index = l
	while index < r && 0 < rnd do
		rnd -= mapArray[index][1]
		index += 1
	end

	# 文章生成とか
	text += mapArray[index][0][1]
	lim -= mapArray[index][0][1].length
	w1 = w2
	w2 = mapArray[index][0][1]

end

# twitterにツイート
puts text
$client.update(text)
