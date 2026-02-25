require "test_helper"

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = Contact.new(name: "テスト太郎", email: "test@example.com", message: "テストメッセージ")
  end

  test "有効な属性で保存できる" do
    assert_predicate @contact, :valid?
  end

  test "nameが未入力の場合は無効" do
    @contact.name = ""

    assert_not @contact.valid?
    assert_includes @contact.errors.full_messages_for(:name).join, "お名前"
  end

  test "nameが100文字以内なら有効" do
    @contact.name = "あ" * 100

    assert_predicate @contact, :valid?
  end

  test "nameが101文字以上なら無効" do
    @contact.name = "あ" * 101

    assert_not @contact.valid?
    assert_includes @contact.errors[:name], "は100文字以内で入力してください"
  end

  test "emailが未入力の場合は無効" do
    @contact.email = ""

    assert_not @contact.valid?
    assert_includes @contact.errors.full_messages_for(:email).join, "メールアドレス"
  end

  test "emailが不正な形式の場合は無効" do
    @contact.email = "invalid-email"

    assert_not @contact.valid?
    assert_predicate @contact.errors[:email], :any?
  end

  test "emailが正しい形式なら有効" do
    @contact.email = "user@example.com"

    assert_predicate @contact, :valid?
  end

  test "messageが未入力の場合は無効" do
    @contact.message = ""

    assert_not @contact.valid?
    assert_includes @contact.errors.full_messages_for(:message).join, "お問い合わせ内容"
  end

  test "messageが5000文字以内なら有効" do
    @contact.message = "あ" * 5000

    assert_predicate @contact, :valid?
  end

  test "messageが5001文字以上なら無効" do
    @contact.message = "あ" * 5001

    assert_not @contact.valid?
    assert_includes @contact.errors[:message], "は5000文字以内で入力してください"
  end
end
