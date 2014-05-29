txt = gets()
# URLを削除
txt = txt.gsub(/(https?:\/\/)?([\w*%#!()~\'-]+\.)+[\w*%#!()~\'-]+(\/[\w*%#!()~\'-.]+)*/, "")
puts txt
# メンションを削除
txt = txt.gsub(/@[0-9a-zA-Z_]{1,15}/, "")
puts txt
# ハッシュタグを削除
txt = txt.gsub(/#[0-9a-zA-Z]+/, "")
puts txt
