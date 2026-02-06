# 相手（recipients）
recipients = %w[親 パートナー 友人 兄弟・姉妹 祖父母 職場の人 その他]
recipients.each.with_index(1) do |name, i|
  Recipient.find_or_create_by!(name: name) do |r|
    r.position = i
  end
end

# きっかけ（occasions）
occasions = [
  "誕生日・記念日",
  "日頃の感謝",
  "最近助けてもらった",
  "しばらく会えていない",
  "特別な理由はない",
  "その他"
]
occasions.each.with_index(1) do |name, i|
  Occasion.find_or_create_by!(name: name) do |r|
    r.position = i
  end
end

# 印象（impressions）
impressions = %w[いつも支えてくれる 一緒にいると安心する 自分を理解してくれる 困ったときに頼れる 笑顔にしてくれる 尊敬している 刺激をもらえる]
impressions.each.with_index(1) do |name, i|
  Impression.find_or_create_by!(name: name) do |r|
    r.position = i
  end
end

# 気持ち（feelings）
feelings = [
  "ありがとう",
  "これからもよろしく",
  "いつも助かっている",
  "大切に思っている",
  "ごめんね、そしてありがとう"
]
feelings.each.with_index(1) do |name, i|
  Feeling.find_or_create_by!(name: name) do |r|
    r.position = i
  end
end

Rails.logger.info "Seed data loaded successfully!"
Rails.logger.info "  Recipients:  #{Recipient.count}"
Rails.logger.info "  Occasions:   #{Occasion.count}"
Rails.logger.info "  Impressions: #{Impression.count}"
Rails.logger.info "  Feelings:    #{Feeling.count}"
