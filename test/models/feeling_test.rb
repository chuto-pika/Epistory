require "test_helper"

class FeelingTest < ActiveSupport::TestCase
  test "有効な属性で保存できる" do
    feeling = Feeling.new(name: "ありがとう", position: 1)

    assert_predicate feeling, :valid?
  end

  test "nameが空の場合は無効" do
    feeling = Feeling.new(name: "", position: 1)

    assert_not feeling.valid?
    assert_includes feeling.errors[:name], "can't be blank"
  end

  test "nameがnilの場合は無効" do
    feeling = Feeling.new(name: nil, position: 1)

    assert_not feeling.valid?
  end

  test "positionが空の場合は無効" do
    feeling = Feeling.new(name: "ありがとう", position: nil)

    assert_not feeling.valid?
    assert_includes feeling.errors[:position], "can't be blank"
  end

  test "positionが整数でない場合は無効" do
    feeling = Feeling.new(name: "ありがとう", position: 1.5)

    assert_not feeling.valid?
    assert_includes feeling.errors[:position], "must be an integer"
  end

  test "default_scopeでpositionの昇順に並ぶ" do
    Feeling.unscoped.delete_all
    third = Feeling.create!(name: "いつも助かっている", position: 3)
    first = Feeling.create!(name: "ありがとう", position: 1)
    second = Feeling.create!(name: "これからもよろしく", position: 2)

    feelings = Feeling.all

    assert_equal [first, second, third], feelings.to_a
  end
end
