require "test_helper"

class SidebarTest < ActionDispatch::IntegrationTest
  test "sidebar is not displayed for guests" do
    get root_path

    assert_response :success
    assert_no_match "メッセージ履歴", response.body
  end

  test "sidebar is displayed for logged in user" do
    sign_in_as(users(:alice))
    create_message_via_steps

    get root_path

    assert_response :success
    assert_match "メッセージ履歴", response.body
  end

  test "sidebar shows only own messages" do
    # aliceがメッセージ作成
    sign_in_as(users(:alice))
    alice_message = create_message_via_steps

    # bobでログインし直す
    reset!
    sign_in_as(users(:bob))
    bob_message = create_message_via_steps

    get root_path

    assert_response :success
    # サイドバーにbobのメッセージへのリンクがある
    assert_select "aside a[href='#{message_path(bob_message)}']"
    # aliceのメッセージへのリンクはない
    assert_select "aside a[href='#{message_path(alice_message)}']", count: 0
  end

  test "sidebar shows empty state when no messages" do
    sign_in_as(users(:alice))

    get root_path

    assert_response :success
    assert_match "まだメッセージがありません", response.body
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
