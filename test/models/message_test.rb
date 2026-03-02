require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @recipient = Recipient.find_or_create_by!(name: "親", position: 1)
    @occasion = Occasion.find_or_create_by!(name: "誕生日・記念日", position: 1)
    @feeling = Feeling.find_or_create_by!(name: "ありがとう", position: 1)
    @impression = Impression.find_or_create_by!(name: "いつも支えてくれる", position: 1)
  end

  test "有効な属性で保存できる" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      episode: "テストエピソード"
    )

    assert_predicate message, :valid?
  end

  test "recipientが未設定の場合は無効" do
    message = Message.new(
      recipient: nil,
      occasion: @occasion,
      feeling: @feeling
    )

    assert_not message.valid?
    assert_includes message.errors[:recipient], "を選んでください"
  end

  test "occasionが未設定の場合は無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: nil,
      feeling: @feeling
    )

    assert_not message.valid?
    assert_includes message.errors[:occasion], "を選んでください"
  end

  test "feelingが未設定の場合は無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: nil
    )

    assert_not message.valid?
    assert_includes message.errors[:feeling], "を選んでください"
  end

  test "impressionsを関連付けできる" do
    message = Message.create!(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      episode: "テストエピソード"
    )
    message.impressions << @impression

    assert_equal [@impression], message.impressions.to_a
  end

  test "additional_messageはnullでも有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      additional_message: nil
    )

    assert_predicate message, :valid?
  end

  test "edited_contentはnullでも有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      edited_content: nil
    )

    assert_predicate message, :valid?
  end

  test "user_idはnullでも有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      user_id: nil
    )

    assert_predicate message, :valid?
  end

  test "episodeが500文字以内なら有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      episode: "あ" * 500
    )

    assert_predicate message, :valid?
  end

  test "episodeが501文字以上なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      episode: "あ" * 501
    )

    assert_not message.valid?
    assert_includes message.errors[:episode], "は500文字以内で入力してください"
  end

  test "additional_messageが200文字以内なら有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      additional_message: "あ" * 200
    )

    assert_predicate message, :valid?
  end

  test "additional_messageが201文字以上なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      additional_message: "あ" * 201
    )

    assert_not message.valid?
    assert_includes message.errors[:additional_message], "は200文字以内で入力してください"
  end

  test "recipient_nameが20文字以内なら有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      recipient_name: "あ" * 20
    )

    assert_predicate message, :valid?
  end

  test "recipient_nameが21文字以上なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      recipient_name: "あ" * 21
    )

    assert_not message.valid?
    assert_includes message.errors[:recipient_name], "は20文字以内で入力してください"
  end

  test "recipient_nameはnullでも有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      recipient_name: nil
    )

    assert_predicate message, :valid?
  end

  # === satisfaction_rating ===
  test "satisfaction_ratingが1〜5なら有効" do
    (1..5).each do |rating|
      message = Message.new(
        recipient: @recipient,
        occasion: @occasion,
        feeling: @feeling,
        satisfaction_rating: rating
      )

      assert_predicate message, :valid?, "rating #{rating} should be valid"
    end
  end

  test "satisfaction_ratingが0なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      satisfaction_rating: 0
    )

    assert_not message.valid?
  end

  test "satisfaction_ratingが6なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      satisfaction_rating: 6
    )

    assert_not message.valid?
  end

  test "satisfaction_ratingがnilなら有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      satisfaction_rating: nil
    )

    assert_predicate message, :valid?
  end

  # === usage_purpose ===
  test "usage_purposeが有効な値なら有効" do
    Message::USAGE_PURPOSE_OPTIONS.each do |purpose|
      message = Message.new(
        recipient: @recipient,
        occasion: @occasion,
        feeling: @feeling,
        usage_purpose: purpose
      )

      assert_predicate message, :valid?, "purpose #{purpose} should be valid"
    end
  end

  test "usage_purposeが無効な値なら無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      usage_purpose: "invalid_value"
    )

    assert_not message.valid?
  end

  test "usage_purposeがnilなら有効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      usage_purpose: nil
    )

    assert_predicate message, :valid?
  end

  # === survey_answered? ===
  test "survey_answered?はsatisfaction_ratingがあればtrueを返す" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      satisfaction_rating: 3
    )

    assert_predicate message, :survey_answered?
  end

  test "survey_answered?はsatisfaction_ratingがnilならfalseを返す" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      satisfaction_rating: nil
    )

    assert_not_predicate message, :survey_answered?
  end
end
