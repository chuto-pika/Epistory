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
    assert_includes message.errors[:recipient], "must exist"
  end

  test "occasionが未設定の場合は無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: nil,
      feeling: @feeling
    )

    assert_not message.valid?
    assert_includes message.errors[:occasion], "must exist"
  end

  test "feelingが未設定の場合は無効" do
    message = Message.new(
      recipient: @recipient,
      occasion: @occasion,
      feeling: nil
    )

    assert_not message.valid?
    assert_includes message.errors[:feeling], "must exist"
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
end
