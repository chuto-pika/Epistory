require "test_helper"

class RecipientTest < ActiveSupport::TestCase
  test "有効な属性で保存できる" do
    recipient = Recipient.new(name: "親", position: 1)

    assert_predicate recipient, :valid?
  end

  test "nameが空の場合は無効" do
    recipient = Recipient.new(name: "", position: 1)

    assert_not recipient.valid?
    assert_includes recipient.errors[:name], "を入力してください"
  end

  test "nameがnilの場合は無効" do
    recipient = Recipient.new(name: nil, position: 1)

    assert_not recipient.valid?
  end

  test "positionが空の場合は無効" do
    recipient = Recipient.new(name: "親", position: nil)

    assert_not recipient.valid?
    assert_includes recipient.errors[:position], "を入力してください"
  end

  test "positionが整数でない場合は無効" do
    recipient = Recipient.new(name: "親", position: 1.5)

    assert_not recipient.valid?
    assert_includes recipient.errors[:position], "は整数で入力してください"
  end

  test "default_scopeでpositionの昇順に並ぶ" do
    Recipient.unscoped.delete_all
    third = Recipient.create!(name: "友人", position: 3)
    first = Recipient.create!(name: "親", position: 1)
    second = Recipient.create!(name: "パートナー", position: 2)

    recipients = Recipient.all

    assert_equal [first, second, third], recipients.to_a
  end
end
