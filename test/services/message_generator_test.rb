require "test_helper"

class MessageGeneratorTest < ActiveSupport::TestCase
  setup do
    @recipient_parent = Recipient.find_or_create_by!(name: "親", position: 1)
    @recipient_partner = Recipient.find_or_create_by!(name: "パートナー", position: 2)
    @recipient_friend = Recipient.find_or_create_by!(name: "友人", position: 3)
    @recipient_sibling = Recipient.find_or_create_by!(name: "兄弟・姉妹", position: 4)
    @recipient_grandparent = Recipient.find_or_create_by!(name: "祖父母", position: 5)
    @recipient_colleague = Recipient.find_or_create_by!(name: "職場の人", position: 6)
    @recipient_other = Recipient.find_or_create_by!(name: "その他", position: 7)

    @occasion_birthday = Occasion.find_or_create_by!(name: "誕生日・記念日", position: 1)
    @occasion_thanks = Occasion.find_or_create_by!(name: "日頃の感謝", position: 2)
    @occasion_helped = Occasion.find_or_create_by!(name: "最近助けてもらった", position: 3)
    @occasion_apart = Occasion.find_or_create_by!(name: "しばらく会えていない", position: 4)
    @occasion_noreason = Occasion.find_or_create_by!(name: "特別な理由はない", position: 5)
    @occasion_other = Occasion.find_or_create_by!(name: "その他", position: 6)

    @impression1 = Impression.find_or_create_by!(name: "いつも支えてくれる", position: 1)
    @impression2 = Impression.find_or_create_by!(name: "一緒にいると安心する", position: 2)
    @impression3 = Impression.find_or_create_by!(name: "笑顔にしてくれる", position: 3)

    @feeling_thanks = Feeling.find_or_create_by!(name: "ありがとう", position: 1)
    @feeling_yoroshiku = Feeling.find_or_create_by!(name: "これからもよろしく", position: 2)
    @feeling_tasukaru = Feeling.find_or_create_by!(name: "いつも助かっている", position: 3)
    @feeling_taisetsu = Feeling.find_or_create_by!(name: "大切に思っている", position: 4)
    @feeling_gomenne = Feeling.find_or_create_by!(name: "ごめんね、そしてありがとう", position: 5)
  end

  def build_message(recipient: nil, occasion: nil, feeling: nil, impressions: [], episode: nil, additional_message: nil)
    msg = Message.create!(
      recipient: recipient || @recipient_parent,
      occasion: occasion || @occasion_thanks,
      feeling: feeling || @feeling_thanks,
      episode: episode,
      additional_message: additional_message
    )
    impressions.each { |imp| msg.impressions << imp }
    msg
  end

  # --- 基本動作 ---

  test "generateでメッセージ文字列が生成される" do
    message = build_message(impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_kind_of String, result
    assert_predicate result, :present?
  end

  # --- recipient に応じた呼称 ---

  test "親の場合はお父さん・お母さんへの呼称が含まれる" do
    message = build_message(recipient: @recipient_parent, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
  end

  test "パートナーの場合はあなたへの呼称が含まれる" do
    message = build_message(recipient: @recipient_partner, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/あなたへ/, result)
  end

  test "友人の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_friend, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつもありがとうへ/, result)
  end

  test "祖父母の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_grandparent, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/おじいちゃん・おばあちゃんへ/, result)
  end

  test "職場の人の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_colleague, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつもお世話になっていますへ/, result)
  end

  test "その他の場合は呼称なしで始まる" do
    message = build_message(recipient: @recipient_other, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_no_match(/へ\n/, result)
  end

  # --- occasion に応じた導入文 ---

  test "誕生日・記念日の導入文が生成される" do
    message = build_message(occasion: @occasion_birthday, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::OCCASION_TEMPLATES["誕生日・記念日"]

    assert templates.any? { |t| result.include?(t) }, "導入文がいずれかのテンプレートにマッチすること"
  end

  test "日頃の感謝の導入文が生成される" do
    message = build_message(occasion: @occasion_thanks, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::OCCASION_TEMPLATES["日頃の感謝"]

    assert templates.any? { |t| result.include?(t) }, "導入文がいずれかのテンプレートにマッチすること"
  end

  test "最近助けてもらったの導入文が生成される" do
    message = build_message(occasion: @occasion_helped, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::OCCASION_TEMPLATES["最近助けてもらった"]

    assert templates.any? { |t| result.include?(t) }, "導入文がいずれかのテンプレートにマッチすること"
  end

  test "しばらく会えていないの導入文が生成される" do
    message = build_message(occasion: @occasion_apart, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::OCCASION_TEMPLATES["しばらく会えていない"]

    assert templates.any? { |t| result.include?(t) }, "導入文がいずれかのテンプレートにマッチすること"
  end

  test "特別な理由はないの導入文が生成される" do
    message = build_message(occasion: @occasion_noreason, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::OCCASION_TEMPLATES["特別な理由はない"]

    assert templates.any? { |t| result.include?(t) }, "導入文がいずれかのテンプレートにマッチすること"
  end

  test "その他のoccasionの導入文が生成される" do
    message = build_message(occasion: @occasion_other, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/伝えたい気持ちがあって/, result)
  end

  # --- impressions ---

  test "impression1つの場合は描写テンプレートが使われる" do
    message = build_message(impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]

    assert templates.any? { |t| result.include?(t) }, "印象描写がテンプレートにマッチすること"
  end

  test "impression2つの場合は両方の描写が含まれる" do
    message = build_message(impressions: [@impression1, @impression2])
    result = MessageGenerator.new(message).generate

    templates1 = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]
    templates2 = MessageGenerator::IMPRESSION_TEMPLATES["一緒にいると安心する"]

    assert templates1.any? { |t| result.include?(t) }, "1つ目の印象描写が含まれること"
    assert templates2.any? { |t| result.include?(t) }, "2つ目の印象描写が含まれること"
  end

  test "impression3つの場合は全ての描写が含まれる" do
    message = build_message(impressions: [@impression1, @impression2, @impression3])
    result = MessageGenerator.new(message).generate

    templates1 = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]
    templates2 = MessageGenerator::IMPRESSION_TEMPLATES["一緒にいると安心する"]
    templates3 = MessageGenerator::IMPRESSION_TEMPLATES["笑顔にしてくれる"]

    assert templates1.any? { |t| result.include?(t) }, "1つ目の印象描写が含まれること"
    assert templates2.any? { |t| result.include?(t) }, "2つ目の印象描写が含まれること"
    assert templates3.any? { |t| result.include?(t) }, "3つ目の印象描写が含まれること"
  end

  test "impressionが0個の場合は印象セクションが含まれない" do
    message = build_message(impressions: [])
    result = MessageGenerator.new(message).generate

    MessageGenerator::IMPRESSION_TEMPLATES.each_value do |templates|
      templates.each do |t|
        assert_not_includes result, t
      end
    end
  end

  # --- episode ---

  test "エピソードが含まれ導入文と接続文が付与される" do
    message = build_message(impressions: [@impression1], episode: "先日、体調を崩したときにそばにいてくれました。")
    result = MessageGenerator.new(message).generate

    assert_match(/先日、体調を崩したときにそばにいてくれました。/, result)
    intros = MessageGenerator::EPISODE_INTROS
    outros = MessageGenerator::EPISODE_OUTROS

    assert intros.any? { |t| result.include?(t) }, "エピソード導入文が含まれること"
    assert outros.any? { |t| result.include?(t) }, "エピソード接続文が含まれること"
  end

  test "エピソードが空の場合はエピソードセクションが含まれない" do
    message = build_message(impressions: [@impression1], episode: nil)
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
    MessageGenerator::EPISODE_INTROS.each do |intro|
      assert_not_includes result, intro
    end
  end

  # --- feeling ---

  test "ありがとうの締めくくりが生成される" do
    message = build_message(feeling: @feeling_thanks, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::FEELING_TEMPLATES["ありがとう"]

    assert templates.any? { |t| result.include?(t) }, "締めくくりがテンプレートにマッチすること"
  end

  test "これからもよろしくの締めくくりが生成される" do
    message = build_message(feeling: @feeling_yoroshiku, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::FEELING_TEMPLATES["これからもよろしく"]

    assert templates.any? { |t| result.include?(t) }, "締めくくりがテンプレートにマッチすること"
  end

  test "いつも助かっているの締めくくりが生成される" do
    message = build_message(feeling: @feeling_tasukaru, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::FEELING_TEMPLATES["いつも助かっている"]

    assert templates.any? { |t| result.include?(t) }, "締めくくりがテンプレートにマッチすること"
  end

  test "大切に思っているの締めくくりが生成される" do
    message = build_message(feeling: @feeling_taisetsu, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::FEELING_TEMPLATES["大切に思っている"]

    assert templates.any? { |t| result.include?(t) }, "締めくくりがテンプレートにマッチすること"
  end

  test "ごめんね、そしてありがとうの締めくくりが生成される" do
    message = build_message(feeling: @feeling_gomenne, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    templates = MessageGenerator::FEELING_TEMPLATES["ごめんね、そしてありがとう"]

    assert templates.any? { |t| result.include?(t) }, "締めくくりがテンプレートにマッチすること"
  end

  # --- additional_message ---

  test "追加メッセージがある場合はP.S.として追加される" do
    message = build_message(impressions: [@impression1], additional_message: "今度ご飯行こうね！")
    result = MessageGenerator.new(message).generate

    assert_match(/P\.S\. 今度ご飯行こうね！/, result)
  end

  test "追加メッセージがない場合はP.S.が含まれない" do
    message = build_message(impressions: [@impression1], additional_message: nil)
    result = MessageGenerator.new(message).generate

    assert_no_match(/P\.S\./, result)
  end

  # --- 組み合わせテスト ---

  test "全要素を含むメッセージが正しく生成される" do
    message = build_message(
      recipient: @recipient_parent,
      occasion: @occasion_birthday,
      feeling: @feeling_thanks,
      impressions: [@impression1, @impression2],
      episode: "いつも応援してくれてありがとう。",
      additional_message: "また帰るね。"
    )
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
    occasion_templates = MessageGenerator::OCCASION_TEMPLATES["誕生日・記念日"]

    assert occasion_templates.any? { |t| result.include?(t) }, "導入文が含まれること"
    imp1_templates = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]
    imp2_templates = MessageGenerator::IMPRESSION_TEMPLATES["一緒にいると安心する"]

    assert imp1_templates.any? { |t| result.include?(t) }, "印象1の描写が含まれること"
    assert imp2_templates.any? { |t| result.include?(t) }, "印象2の描写が含まれること"
    assert_match(/いつも応援してくれてありがとう。/, result)
    feeling_templates = MessageGenerator::FEELING_TEMPLATES["ありがとう"]

    assert feeling_templates.any? { |t| result.include?(t) }, "締めくくりが含まれること"
    assert_match(/P\.S\. また帰るね。/, result)
  end

  test "recipientとoccasionの異なる組み合わせで導入文が変化する" do
    msg1 = build_message(recipient: @recipient_partner, occasion: @occasion_birthday, impressions: [@impression1])
    msg2 = build_message(recipient: @recipient_partner, occasion: @occasion_apart, impressions: [@impression1])

    result1 = MessageGenerator.new(msg1).generate
    result2 = MessageGenerator.new(msg2).generate

    templates1 = MessageGenerator::OCCASION_TEMPLATES["誕生日・記念日"]
    templates2 = MessageGenerator::OCCASION_TEMPLATES["しばらく会えていない"]

    assert templates1.any? { |t| result1.include?(t) }, "誕生日の導入文が含まれること"
    assert templates2.any? { |t| result2.include?(t) }, "しばらく会えていないの導入文が含まれること"
    assert_match(/あなたへ/, result1)
    assert_match(/あなたへ/, result2)
  end

  # --- バリエーションテスト ---

  test "同じ入力でも生成構造が正しい" do
    message = build_message(
      recipient: @recipient_parent,
      occasion: @occasion_thanks,
      feeling: @feeling_thanks,
      impressions: [@impression1],
      episode: "テストエピソード"
    )

    results = 5.times.map { MessageGenerator.new(message).generate }

    results.each do |result|
      assert_match(/お父さん・お母さんへ/, result)
      imp_templates = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]

      assert imp_templates.any? { |t| result.include?(t) }, "印象描写が含まれること"
      assert_match(/テストエピソード/, result)
    end
  end
end
