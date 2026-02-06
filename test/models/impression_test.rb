require "test_helper"

class ImpressionTest < ActiveSupport::TestCase
  test "有効な属性で保存できる" do
    impression = Impression.new(name: "いつも支えてくれる", position: 1)
    assert impression.valid?
  end

  test "nameが空の場合は無効" do
    impression = Impression.new(name: "", position: 1)
    assert_not impression.valid?
    assert_includes impression.errors[:name], "can't be blank"
  end

  test "nameがnilの場合は無効" do
    impression = Impression.new(name: nil, position: 1)
    assert_not impression.valid?
  end

  test "positionが空の場合は無効" do
    impression = Impression.new(name: "いつも支えてくれる", position: nil)
    assert_not impression.valid?
    assert_includes impression.errors[:position], "can't be blank"
  end

  test "positionが整数でない場合は無効" do
    impression = Impression.new(name: "いつも支えてくれる", position: 1.5)
    assert_not impression.valid?
    assert_includes impression.errors[:position], "must be an integer"
  end

  test "default_scopeでpositionの昇順に並ぶ" do
    Impression.unscoped.delete_all
    third = Impression.create!(name: "自分を理解してくれる", position: 3)
    first = Impression.create!(name: "いつも支えてくれる", position: 1)
    second = Impression.create!(name: "一緒にいると安心する", position: 2)

    impressions = Impression.all
    assert_equal [first, second, third], impressions.to_a
  end
end
