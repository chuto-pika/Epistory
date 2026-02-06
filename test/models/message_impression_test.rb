require "test_helper"

class MessageImpressionTest < ActiveSupport::TestCase
  setup do
    @recipient = Recipient.find_or_create_by!(name: "親", position: 1)
    @occasion = Occasion.find_or_create_by!(name: "誕生日・記念日", position: 1)
    @feeling = Feeling.find_or_create_by!(name: "ありがとう", position: 1)
    @impression = Impression.find_or_create_by!(name: "いつも支えてくれる", position: 1)
    @message = Message.create!(
      recipient: @recipient,
      occasion: @occasion,
      feeling: @feeling,
      episode: "テストエピソード"
    )
  end

  test "有効な属性で保存できる" do
    mi = MessageImpression.new(message: @message, impression: @impression)

    assert_predicate mi, :valid?
  end

  test "messageが未設定の場合は無効" do
    mi = MessageImpression.new(message: nil, impression: @impression)

    assert_not mi.valid?
  end

  test "impressionが未設定の場合は無効" do
    mi = MessageImpression.new(message: @message, impression: nil)

    assert_not mi.valid?
  end
end
