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

  # === destroy ===
  test "logged in user can delete own message" do
    sign_in_as(users(:alice))
    message = create_message_via_steps

    assert_difference("Message.count", -1) do
      delete message_path(message)
    end
  end

  test "logged in user cannot delete others message" do
    sign_in_as(users(:alice))
    message = create_message_via_steps

    reset!
    sign_in_as(users(:bob))

    assert_no_difference("Message.count") do
      delete message_path(message)
    end

    assert_redirected_to root_path
  end

  test "guest cannot delete message without session" do
    message = create_message_via_steps
    reset!

    assert_no_difference("Message.count") do
      delete message_path(message)
    end

    assert_redirected_to root_path
  end

  # === regenerate ===
  test "regenerate updates generated_content" do
    message = create_message_via_steps
    original_content = message.generated_content

    patch regenerate_message_path(message)
    message.reload

    assert_not_equal original_content, message.generated_content
  end

  test "regenerate resets edited_content to nil" do
    message = create_message_via_steps
    message.update!(edited_content: "ユーザー編集済み")

    patch regenerate_message_path(message)

    assert_nil message.reload.edited_content
  end

  test "regenerate redirects to show" do
    message = create_message_via_steps

    patch regenerate_message_path(message)

    assert_redirected_to message_path(message)
  end

  test "logged in user cannot regenerate others message" do
    sign_in_as(users(:alice))
    message = create_message_via_steps
    original_content = message.generated_content

    reset!
    sign_in_as(users(:bob))

    patch regenerate_message_path(message)

    assert_redirected_to root_path
    assert_equal original_content, message.reload.generated_content
  end

  test "guest cannot regenerate message without session" do
    message = create_message_via_steps
    original_content = message.generated_content
    reset!

    patch regenerate_message_path(message)

    assert_redirected_to root_path
    assert_equal original_content, message.reload.generated_content
  end

  test "regenerate sets generated_parts" do
    message = create_message_via_steps

    patch regenerate_message_path(message)
    message.reload

    assert_predicate message, :parts_available?
    assert_includes message.generated_parts.keys, "opening"
    assert_includes message.generated_parts.keys, "closing"
  end

  # === regenerate_part ===
  test "regenerate_part updates only the specified part" do
    message = create_message_via_steps
    # regenerateで generated_parts を付与
    patch regenerate_message_path(message)
    message.reload

    original_opening = message.generated_parts["opening"]

    patch regenerate_part_message_path(message), params: { part: "closing" }
    message.reload

    # openingは変わらない
    assert_equal original_opening, message.generated_parts["opening"]
    # closingは変わりうる（テンプレートが複数あるため）
    assert_predicate message.generated_parts["closing"], :present?
    # generated_contentが再構築される
    assert_predicate message.generated_content, :present?
  end

  test "regenerate_part rejects invalid part name" do
    message = create_message_via_steps
    patch regenerate_message_path(message)

    patch regenerate_part_message_path(message), params: { part: "invalid" }

    assert_redirected_to message_path(message)
    assert_equal "無効なパートです", flash[:alert]
  end

  test "regenerate_part rejects ps part" do
    message = create_message_via_steps
    patch regenerate_message_path(message)

    patch regenerate_part_message_path(message), params: { part: "ps" }

    assert_redirected_to message_path(message)
    assert_equal "無効なパートです", flash[:alert]
  end

  test "regenerate_part clears edited_content" do
    message = create_message_via_steps
    patch regenerate_message_path(message)
    message.update!(edited_content: "編集済み")

    patch regenerate_part_message_path(message), params: { part: "opening" }
    message.reload

    assert_nil message.edited_content
    assert_predicate message.generated_parts["opening"], :present?
  end

  test "regenerate_part rejects legacy message without generated_parts" do
    message = create_message_via_steps
    # generated_partsがnilの状態（レガシー）
    message.update!(generated_parts: nil)

    patch regenerate_part_message_path(message), params: { part: "opening" }

    assert_redirected_to message_path(message)
    assert_equal "パート別再生成に対応していないメッセージです", flash[:alert]
  end

  test "regenerate_part responds with turbo_stream" do
    message = create_message_via_steps
    patch regenerate_message_path(message)

    patch regenerate_part_message_path(message),
          params: { part: "opening" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.body, "message_part_opening"
  end

  test "logged in user cannot regenerate_part others message" do
    sign_in_as(users(:alice))
    message = create_message_via_steps
    patch regenerate_message_path(message)

    reset!
    sign_in_as(users(:bob))

    patch regenerate_part_message_path(message), params: { part: "opening" }

    assert_redirected_to root_path
  end

  test "guest cannot regenerate_part without session" do
    message = create_message_via_steps
    patch regenerate_message_path(message)
    reset!

    patch regenerate_part_message_path(message), params: { part: "opening" }

    assert_redirected_to root_path
  end

  # === survey ===
  test "survey saves satisfaction_rating" do
    message = create_message_via_steps

    patch survey_message_path(message), params: { message: { satisfaction_rating: 4 } }

    assert_equal 4, message.reload.satisfaction_rating
  end

  test "survey saves usage_purpose" do
    message = create_message_via_steps

    patch survey_message_path(message), params: { message: { satisfaction_rating: 5, usage_purpose: "send_as_is" } }

    assert_equal 5, message.reload.satisfaction_rating
    assert_equal "send_as_is", message.reload.usage_purpose
  end

  test "survey responds with turbo_stream" do
    message = create_message_via_steps

    patch survey_message_path(message), params: { message: { satisfaction_rating: 3 } },
                                        headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.body, "survey_#{message.id}"
    assert_includes response.body, "ご回答ありがとうございます"
  end

  test "survey does not overwrite answered survey" do
    message = create_message_via_steps
    message.update!(satisfaction_rating: 3, usage_purpose: "reference")

    patch survey_message_path(message), params: { message: { satisfaction_rating: 5, usage_purpose: "send_as_is" } }

    assert_equal 3, message.reload.satisfaction_rating
    assert_equal "reference", message.reload.usage_purpose
  end

  test "survey is rejected for non-owner" do
    sign_in_as(users(:alice))
    message = create_message_via_steps

    reset!
    sign_in_as(users(:bob))

    patch survey_message_path(message), params: { message: { satisfaction_rating: 4 } }

    assert_redirected_to root_path
    assert_nil message.reload.satisfaction_rating
  end

  test "show displays survey for owner with unanswered survey" do
    message = create_message_via_steps

    get message_path(message)

    assert_response :success
    assert_select "[data-controller='survey']"
  end

  test "show does not display survey for non-owner" do
    message = create_message_via_steps
    reset!

    get message_path(message)

    assert_response :success
    assert_select "[data-controller='survey']", count: 0
  end

  test "show does not display survey when already answered" do
    message = create_message_via_steps
    message.update!(satisfaction_rating: 4)

    get message_path(message)

    assert_response :success
    assert_select "[data-controller='survey']", count: 0
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
