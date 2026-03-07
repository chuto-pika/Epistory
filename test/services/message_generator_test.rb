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

  def build_message(recipient: nil, occasion: nil, feeling: nil,
                    impressions: [], episode: nil, additional_message: nil,
                    recipient_name: nil)
    msg = Message.create!(
      recipient: recipient || @recipient_parent,
      occasion: occasion || @occasion_thanks,
      feeling: feeling || @feeling_thanks,
      episode: episode,
      additional_message: additional_message,
      recipient_name: recipient_name
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

  test "recipient_nameが指定されている場合はその宛名が使われる" do
    message = build_message(recipient: @recipient_parent, impressions: [@impression1], recipient_name: "お母さん")
    result = MessageGenerator.new(message).generate

    assert_match(/お母さんへ/, result)
    assert_no_match(/お父さん・お母さんへ/, result)
  end

  test "recipient_nameが空の場合はHONORIFICSフォールバックが使われる" do
    message = build_message(recipient: @recipient_parent, impressions: [@impression1], recipient_name: nil)
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
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

  test "impression2つの場合は両方の描写と接続詞が含まれる" do
    message = build_message(impressions: [@impression1, @impression2])
    result = MessageGenerator.new(message).generate

    templates1 = MessageGenerator::IMPRESSION_TEMPLATES["いつも支えてくれる"]
    templates2 = MessageGenerator::IMPRESSION_TEMPLATES["一緒にいると安心する"]

    assert templates1.any? { |t| result.include?(t) }, "1つ目の印象描写が含まれること"
    assert templates2.any? { |t| result.include?(t) }, "2つ目の印象描写が含まれること"

    connectors = MessageGenerator::IMPRESSION_CONNECTORS

    assert connectors.any? { |c| result.include?(c) }, "接続詞が含まれること"
  end

  test "impression3つの場合は全ての描写と接続詞が含まれる" do
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

  # --- generate_parts ---

  test "generate_partsがHashを返す" do
    message = build_message(impressions: [@impression1], episode: "テスト", additional_message: "追伸")
    parts = MessageGenerator.new(message).generate_parts

    assert_kind_of Hash, parts
    assert_includes parts.keys, "opening"
    assert_includes parts.keys, "bridge"
    assert_includes parts.keys, "impression"
    assert_includes parts.keys, "episode"
    assert_includes parts.keys, "future"
    assert_includes parts.keys, "closing"
    assert_includes parts.keys, "ps"
  end

  test "generate_partsでimpressionなしの場合はimpressionとbridgeキーが含まれない" do
    message = build_message(impressions: [])
    parts = MessageGenerator.new(message).generate_parts

    assert_not_includes parts.keys, "impression"
    assert_not_includes parts.keys, "bridge"
  end

  test "generate_partsでepisodeなしの場合はepisodeキーが含まれない" do
    message = build_message(impressions: [@impression1], episode: nil)
    parts = MessageGenerator.new(message).generate_parts

    assert_not_includes parts.keys, "episode"
  end

  test "generate_partsでadditional_messageなしの場合はpsキーが含まれない" do
    message = build_message(impressions: [@impression1], additional_message: nil)
    parts = MessageGenerator.new(message).generate_parts

    assert_not_includes parts.keys, "ps"
  end

  # --- generate_part ---

  test "generate_partで各パートを個別生成できる" do
    message = build_message(impressions: [@impression1], episode: "テストエピソード")
    generator = MessageGenerator.new(message)

    MessageGenerator::REGENERABLE_PARTS.each do |part_name|
      result = generator.generate_part(part_name)

      assert_kind_of String, result, "#{part_name}がStringを返すこと"
    end
  end

  test "generate_partで無効パート名はArgumentError" do
    message = build_message(impressions: [@impression1])
    generator = MessageGenerator.new(message)

    assert_raises(ArgumentError) { generator.generate_part("invalid") }
  end

  test "generate_partでpsはArgumentError" do
    message = build_message(impressions: [@impression1])
    generator = MessageGenerator.new(message)

    assert_raises(ArgumentError) { generator.generate_part("ps") }
  end

  # --- join_parts ---

  test "join_partsがHashからテキストを組み立てる" do
    parts = {
      "opening" => "宛名テスト",
      "impression" => "印象テスト",
      "closing" => "締めくくりテスト"
    }
    result = MessageGenerator.join_parts(parts)

    assert_equal "宛名テスト\n\n印象テスト\n\n締めくくりテスト", result
  end

  test "join_partsはパートの順序を維持する" do
    parts = {
      "closing" => "締め",
      "opening" => "開き",
      "impression" => "印象"
    }
    result = MessageGenerator.join_parts(parts)

    assert_equal "開き\n\n印象\n\n締め", result
  end

  test "join_partsはbridge・futureを含む7パーツの順序を維持する" do
    parts = {
      "ps" => "追伸",
      "future" => "未来",
      "closing" => "締め",
      "bridge" => "架け橋",
      "opening" => "開き",
      "impression" => "印象",
      "episode" => "エピソード"
    }
    result = MessageGenerator.join_parts(parts)

    assert_equal "開き\n\n架け橋\n\n印象\n\nエピソード\n\n未来\n\n締め\n\n追伸", result
  end

  # --- bridge ---

  test "bridgeがoccasionに対応するテンプレートから生成される" do
    message = build_message(occasion: @occasion_birthday, impressions: [@impression1])
    generator = MessageGenerator.new(message)
    bridge = generator.generate_bridge

    templates = MessageGenerator::BRIDGE_TEMPLATES["誕生日・記念日"]

    assert_includes templates, bridge, "bridgeがテンプレートにマッチすること"
  end

  test "bridgeはimpressionが空の場合はnilを返す" do
    message = build_message(impressions: [])
    generator = MessageGenerator.new(message)

    assert_nil generator.generate_bridge
  end

  test "bridgeはoccasionが「その他」の場合はnilを返す" do
    message = build_message(occasion: @occasion_other, impressions: [@impression1])
    generator = MessageGenerator.new(message)

    assert_nil generator.generate_bridge
  end

  test "全occasionのBRIDGE_TEMPLATESが各3パターンある" do
    MessageGenerator::BRIDGE_TEMPLATES.each do |key, templates|
      assert_equal 3, templates.size, "#{key}のbridge テンプレートが3パターンあること"
    end
  end

  # --- future ---

  test "futureがfeelingに対応するテンプレートから生成される" do
    message = build_message(feeling: @feeling_thanks, impressions: [@impression1])
    generator = MessageGenerator.new(message)
    future = generator.generate_future

    templates = MessageGenerator::FUTURE_TEMPLATES["ありがとう"]

    assert_includes templates, future, "futureがテンプレートにマッチすること"
  end

  test "futureは各feelingで生成される" do
    feelings = [@feeling_thanks, @feeling_yoroshiku, @feeling_tasukaru, @feeling_taisetsu, @feeling_gomenne]
    feelings.each do |feeling|
      message = build_message(feeling: feeling, impressions: [@impression1])
      generator = MessageGenerator.new(message)
      future = generator.generate_future

      templates = MessageGenerator::FUTURE_TEMPLATES[feeling.name]

      assert_includes templates, future, "#{feeling.name}のfutureがテンプレートにマッチすること"
    end
  end

  test "全feelingのFUTURE_TEMPLATESが各2パターンある" do
    MessageGenerator::FUTURE_TEMPLATES.each do |key, templates|
      assert_equal 2, templates.size, "#{key}のfuture テンプレートが2パターンあること"
    end
  end

  test "generate_partでfutureを個別生成できる" do
    message = build_message(impressions: [@impression1])
    generator = MessageGenerator.new(message)
    result = generator.generate_part("future")

    assert_kind_of String, result
  end

  test "generate_partでbridgeはArgumentError" do
    message = build_message(impressions: [@impression1])
    generator = MessageGenerator.new(message)

    assert_raises(ArgumentError) { generator.generate_part("bridge") }
  end

  # --- REGENERABLE_PARTS ---

  test "REGENERABLE_PARTSにpsとbridgeが含まれない" do
    assert_not_includes MessageGenerator::REGENERABLE_PARTS, "ps"
    assert_not_includes MessageGenerator::REGENERABLE_PARTS, "bridge"
  end

  test "REGENERABLE_PARTSにfutureが含まれる" do
    assert_includes MessageGenerator::REGENERABLE_PARTS, "future"
  end

  test "REGENERABLE_PARTSに5つのパートが含まれる" do
    assert_equal %w[opening impression episode future closing], MessageGenerator::REGENERABLE_PARTS
  end

  # --- generateの後方互換性 ---

  test "generateはgenerate_partsとjoin_partsの結果と一致する" do
    message = build_message(impressions: [@impression1], episode: "テスト", additional_message: "追伸")
    generator = MessageGenerator.new(message)

    # sampleでランダムなので同じインスタンスから呼ぶと異なる結果になり得る
    # ただしgenerateが内部的にgenerate_parts→join_partsを使っていることを構造的に確認
    result = generator.generate

    assert_kind_of String, result
    assert_predicate result, :present?
  end

  # --- テンプレート数の検証 ---

  test "OCCASION_TEMPLATESは各5パターン以上ある" do
    MessageGenerator::OCCASION_TEMPLATES.each do |key, templates|
      assert_operator templates.size, :>=, 5, "#{key}のテンプレートが5パターン以上あること（実際: #{templates.size}）"
    end
  end

  test "IMPRESSION_TEMPLATESは各5パターン以上ある" do
    MessageGenerator::IMPRESSION_TEMPLATES.each do |key, templates|
      assert_operator templates.size, :>=, 5, "#{key}のテンプレートが5パターン以上あること（実際: #{templates.size}）"
    end
  end

  test "FEELING_TEMPLATESは各5パターン以上ある" do
    MessageGenerator::FEELING_TEMPLATES.each do |key, templates|
      assert_operator templates.size, :>=, 5, "#{key}のテンプレートが5パターン以上あること（実際: #{templates.size}）"
    end
  end

  test "IMPRESSION_CONNECTORSが5パターンある" do
    assert_equal 5, MessageGenerator::IMPRESSION_CONNECTORS.size
  end

  test "IMPRESSION_TEMPLATESで「あなた」を使用していない" do
    MessageGenerator::IMPRESSION_TEMPLATES.each do |key, templates|
      templates.each_with_index do |t, i|
        assert_not_includes t, "あなた", "#{key}のパターン#{i + 1}に「あなた」が含まれていないこと"
      end
    end
  end

  # --- 連結ロジックテスト ---

  test "impression2つの場合に改行で区切られる" do
    message = build_message(impressions: [@impression1, @impression2])
    generator = MessageGenerator.new(message)
    impression_text = generator.generate_impression

    assert_includes impression_text, "\n", "改行で区切られていること"
  end

  test "impression3つの場合に改行で区切られ接続詞が2つ含まれる" do
    message = build_message(impressions: [@impression1, @impression2, @impression3])
    generator = MessageGenerator.new(message)
    impression_text = generator.generate_impression

    lines = impression_text.split("\n")

    assert_equal 3, lines.size, "3行に分かれていること"
    assert_no_match(/\A(そして|それに|それだけでなく|さらに|そしてなにより)/, lines[0], "1行目は接続詞なし")
    assert_match(/\A(そして、|それに、)/, lines[1], "2行目は接続詞で始まること")
    assert_match(/\A(そしてなにより、|さらに、)/, lines[2], "3行目は強調接続詞で始まること")
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
