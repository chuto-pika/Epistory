require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "newでフォームが表示される" do
    get contact_path

    assert_response :success
    assert_select "form"
    assert_select "input[name='contact[name]']"
    assert_select "input[name='contact[email]']"
    assert_select "textarea[name='contact[message]']"
  end

  test "有効なパラメータでcreateするとDB保存されリダイレクトする" do
    assert_difference "Contact.count", 1 do
      post contact_path, params: { contact: { name: "テスト太郎", email: "test@example.com", message: "テストメッセージ" } }
    end

    assert_redirected_to contact_complete_path
  end

  test "有効なパラメータでcreateすると通知メールが送信される" do
    assert_enqueued_emails 1 do
      post contact_path, params: { contact: { name: "テスト太郎", email: "test@example.com", message: "テストメッセージ" } }
    end
  end

  test "無効なパラメータでcreateするとフォームが再表示される" do
    assert_no_difference "Contact.count" do
      post contact_path, params: { contact: { name: "", email: "", message: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "form"
  end

  test "completeで完了画面が表示される" do
    get contact_complete_path

    assert_response :success
    assert_select "h1", "お問い合わせありがとうございます"
  end
end
