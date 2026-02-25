require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "notify_adminが正しい内容でメールを送信する" do
    contact = Contact.create!(name: "テスト太郎", email: "test@example.com", message: "テストメッセージです")
    mail = ContactMailer.notify_admin(contact)

    assert_equal ["admin@example.com"], mail.to
    assert_equal "【Epistory】お問い合わせがありました", mail.subject
    assert_match "テスト太郎", mail.body.encoded
    assert_match "test@example.com", mail.body.encoded
    assert_match "テストメッセージです", mail.body.encoded
  end
end
