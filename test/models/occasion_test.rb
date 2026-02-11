require "test_helper"

class OccasionTest < ActiveSupport::TestCase
  test "有効な属性で保存できる" do
    occasion = Occasion.new(name: "誕生日・記念日", position: 1)

    assert_predicate occasion, :valid?
  end

  test "nameが空の場合は無効" do
    occasion = Occasion.new(name: "", position: 1)

    assert_not occasion.valid?
    assert_includes occasion.errors[:name], "を入力してください"
  end

  test "nameがnilの場合は無効" do
    occasion = Occasion.new(name: nil, position: 1)

    assert_not occasion.valid?
  end

  test "positionが空の場合は無効" do
    occasion = Occasion.new(name: "誕生日・記念日", position: nil)

    assert_not occasion.valid?
    assert_includes occasion.errors[:position], "を入力してください"
  end

  test "positionが整数でない場合は無効" do
    occasion = Occasion.new(name: "誕生日・記念日", position: 1.5)

    assert_not occasion.valid?
    assert_includes occasion.errors[:position], "は整数で入力してください"
  end

  test "default_scopeでpositionの昇順に並ぶ" do
    Occasion.unscoped.delete_all
    third = Occasion.create!(name: "最近助けてもらった", position: 3)
    first = Occasion.create!(name: "誕生日・記念日", position: 1)
    second = Occasion.create!(name: "日頃の感謝", position: 2)

    occasions = Occasion.all

    assert_equal [first, second, third], occasions.to_a
  end
end
