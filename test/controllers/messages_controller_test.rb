require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  # === new ===
  test "new initializes session and redirects to step1" do
    get new_message_path

    assert_redirected_to step1_message_path
  end

  # === show ===
  test "show displays the generated message" do
    message = create_message_via_steps

    get message_path(message)

    assert_response :success
  end

  test "show displays back button to step6" do
    message = create_message_via_steps

    get message_path(message)

    assert_select "a[href='#{step6_message_path}'][aria-label='選択画面に戻る']"
    assert_select "section[data-controller='back-navigation']"
  end

  test "show restores draft so back button navigates to step6" do
    message = create_message_via_steps

    # セッションが消えた状態からshowにアクセス
    get message_path(message)

    assert_response :success

    # 戻るボタンのリンク先（step6）にアクセスできる
    get step6_message_path

    assert_response :success
  end

  # === edit ===
  test "edit displays edit form" do
    message = create_message_via_steps

    get edit_message_path(message)

    assert_response :success
    assert_select "textarea"
  end

  # === update ===
  test "update saves edited_content and redirects to show" do
    message = create_message_via_steps

    patch message_path(message), params: { message: { edited_content: "編集済みメッセージ" } }

    assert_redirected_to message_path(message)
    assert_equal "編集済みメッセージ", message.reload.edited_content
  end

  # === restore ===
  test "restore clears edited_content and redirects to edit" do
    message = create_message_via_steps
    message.update(edited_content: "編集済み")

    patch restore_message_path(message)

    assert_redirected_to edit_message_path(message)
    assert_nil message.reload.edited_content
  end

  # === show is public ===
  test "show is accessible without login" do
    message = create_message_via_steps
    # 新しいセッションでアクセス
    reset!
    get message_path(message)

    assert_response :success
  end

  # === authorization ===
  test "logged in user can edit own message" do
    user = users(:alice)
    sign_in_as(user)
    message = create_message_via_steps

    get edit_message_path(message)

    assert_response :success
  end

  test "logged in user cannot edit others message" do
    # aliceがメッセージ作成
    sign_in_as(users(:alice))
    message = create_message_via_steps

    # bobでログインし直す
    reset!
    sign_in_as(users(:bob))
    get edit_message_path(message)

    assert_redirected_to root_path
  end

  test "guest cannot edit message without session" do
    message = create_message_via_steps
    # セッションをリセット
    reset!
    get edit_message_path(message)

    assert_redirected_to root_path
  end

  test "guest can edit message with session" do
    message = create_message_via_steps

    get edit_message_path(message)

    assert_response :success
  end

  private

  def complete_all_steps
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: { impression_ids: [impressions(:supportive).id] }
    post step4_message_path, params: { episode: "テストエピソード" }
    post step5_message_path, params: { feeling_id: feelings(:thanks).id }
  end

  def create_message_via_steps
    complete_all_steps
    post step6_message_path, params: { additional_message: "" }
    Message.last
  end
end
